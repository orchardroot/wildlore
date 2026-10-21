extends TestCase
## The Building Society (core/building_society.gd): honest compound interest on loans, a savings account, automatic
## monthly repayments, letters when you're behind, Mum's sub, the progress limit, old saves, and that none of it
## prints money (see SocietySim).

func _data(badges := 3, cash := 1000) -> GameStateData:
	var d := GameStateData.new()
	d.money = cash
	d.day_count = 100
	for i in badges:
		d.badges.append("b%d" % i)
	if badges > 0:
		d.set_flag(BuildingSociety.FLAG, {"mum": {"owed": 0, "day": 0, "nag": true}})  # Mum's post already came
	return d

func test_data_is_sound() -> void:
	for z in ["manchester_society", "cardiff_society", "edinburgh_society", "belfast_society", "dublin_society"]:
		var b := BuildingSociety.branch(z)
		assert_false(b.is_empty(), "branch " + z)
		assert_true(Wallet.CURRENCIES.has(str(b.cur)))
	assert_eq(BuildingSociety.branch("dublin_society").cur, "eur", "the credit union deals in euros")
	assert_eq(BuildingSociety.branch("cardiff_society").cur, "gbp")
	assert_true(BuildingSociety.branch("nowhere").is_empty())
	for id in BuildingSociety.letter_ids():
		var l := BuildingSociety.letter(id)
		assert_true(str(l.get("from", "")) != "" and not (l.get("text", []) as Array).is_empty(), "letter " + id)
		for t in l.text:
			assert_false(str(t).contains("—"), "no em-dashes in " + id)

func test_quote_is_honest_compound_interest() -> void:
	var q := BuildingSociety.quote(1000, 0.01, 12)
	assert_eq(q.payment, 90, "the annuity is 88.85, nudged up so whole-pound rounding still clears it in 12")
	assert_true(q.total > 1000 and q.total < 1000 + 12 * 10, "total %d" % q.total)
	assert_eq(q.total, q.interest + 1000)
	var sched := BuildingSociety.schedule(1000, 0.01, 12)
	assert_eq(sched.size(), 12, "clears in exactly the term")
	var owed := 1000
	for p in sched:
		owed += BuildingSociety.interest(owed, 0.01, BuildingSociety.MONTH)
		owed -= p
	assert_eq(owed, 0, "the schedule really repays it to the penny")

func test_longer_costs_more_in_total() -> void:
	var a: int = BuildingSociety.quote(1500, 0.01, 6).total
	var b: int = BuildingSociety.quote(1500, 0.01, 12).total
	var c: int = BuildingSociety.quote(1500, 0.01, 24).total
	assert_true(a < b and b < c, "%d %d %d" % [a, b, c])

func test_apr_is_what_a_year_of_it_costs() -> void:
	assert_near(BuildingSociety.apr(0.01), 0.1268, 0.0005)
	assert_true(BuildingSociety.apr(0.01) > 0.12, "more than twelve times the monthly rate")

func test_limit_follows_progress() -> void:
	assert_eq(BuildingSociety.limit(_data(0), "gbp"), 0, "nothing before badge 2")
	assert_eq(BuildingSociety.limit(_data(1), "gbp"), 0)
	assert_eq(BuildingSociety.limit(_data(2), "gbp"), 500 + 1500 * 2)
	assert_true(BuildingSociety.limit(_data(5), "gbp") > BuildingSociety.limit(_data(2), "gbp"))
	assert_true(BuildingSociety.limit(_data(2), "eur") > BuildingSociety.limit(_data(2), "gbp"), "euros: the same worth, more of them")

func test_borrow_pays_in_and_sets_the_clock() -> void:
	var d := _data(3, 100)
	var r := BuildingSociety.borrow(d, "manchester_society", 1000, 12)
	assert_true(r.ok, str(r.get("why", "")))
	assert_eq(d.money, 1100)
	assert_eq(BuildingSociety.owed(d), 1000)
	assert_true(BuildingSociety.has_loan(d))

func test_borrow_refusals() -> void:
	var d := _data(1)
	assert_false(BuildingSociety.borrow(d, "manchester_society", 100, 6).ok, "too early in the story")
	d = _data(3)
	assert_false(BuildingSociety.borrow(d, "manchester_society", BuildingSociety.limit(d, "gbp") + 1, 6).ok, "over the limit")
	assert_false(BuildingSociety.borrow(d, "manchester_society", 0, 6).ok)
	assert_false(BuildingSociety.borrow(d, "manchester_society", 100, 7).ok, "only the terms on the board")
	assert_true(BuildingSociety.borrow(d, "manchester_society", 100, 6).ok)
	assert_false(BuildingSociety.borrow(d, "manchester_society", 100, 6).ok, "one loan at a time")
	assert_eq(d.money, 1100, "refusals take and give nothing")

func test_a_month_takes_the_repayment_from_the_purse() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	var pay := int(BuildingSociety.quote(1000, 0.01, 12).payment)
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_eq(d.money, 1000 - pay)
	assert_eq(BuildingSociety.owed(d), 1000 + 10 - pay, "a month's interest on 1000, less the payment")
	assert_true(BuildingSociety.letters_waiting(d).is_empty(), "no letter when you're paying")

func test_a_whole_loan_runs_to_a_clear() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 600, 6)
	var total := 0
	for m in 8:
		d.day_count += BuildingSociety.MONTH
		var before := d.money
		d.money += 400  # wages
		BuildingSociety.settle(d)
		total += before + 400 - d.money
	assert_false(BuildingSociety.has_loan(d), "cleared")
	assert_eq(total, int(BuildingSociety.quote(600, 0.01, 6).total), "you paid exactly the quoted total")
	assert_true("cleared" in BuildingSociety.letters_waiting(d))

func test_behind_means_a_polite_letter_and_the_interest_keeps_counting() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	d.money = 0
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_eq(d.money, 0, "nothing to take")
	assert_eq(BuildingSociety.missed(d), 1)
	assert_true("late_1" in BuildingSociety.letters_waiting(d))
	assert_eq(BuildingSociety.owed(d), 1010, "the interest went on")
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.missed(d), 2)
	assert_true("late_2" in BuildingSociety.letters_waiting(d))
	assert_false(BuildingSociety.borrow(d, "cardiff_society", 10, 6).ok, "no new borrowing while there's a loan")
	d.money = 5000
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.missed(d), 0, "paid up again")

func test_pat_leaves_you_bus_fare() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	var pay := int(BuildingSociety.quote(1000, 0.01, 12).payment)
	d.money = pay + 2
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.missed(d), 1, "she won't take the last of it")
	assert_eq(d.money, pay + 2)

func test_a_long_absence_catches_up_month_by_month() -> void:
	var d := _data(3, 5000)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	d.day_count += BuildingSociety.MONTH * 3
	BuildingSociety.settle(d)
	var sched := BuildingSociety.schedule(1000, 0.01, 12)
	assert_eq(BuildingSociety.owed(d), _owed_after(1000, sched, 3), "three months' worth, in order")
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.owed(d), _owed_after(1000, sched, 3), "settling twice changes nothing")

func _owed_after(p: int, sched: Array, n: int) -> int:
	var o := p
	for i in n:
		o += BuildingSociety.interest(o, 0.01, BuildingSociety.MONTH)
		o -= int(sched[i])
	return o

func test_early_repayment_charges_only_the_days_you_had_it() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	assert_eq(BuildingSociety.payoff(d), 1000, "same day: no interest")
	d.day_count += BuildingSociety.MONTH / 2
	var p := BuildingSociety.payoff(d)
	assert_true(p > 1000 and p <= 1006, "half a month's interest: %d" % p)
	d.money = p
	var r := BuildingSociety.repay(d, p)
	assert_true(r.ok)
	assert_false(BuildingSociety.has_loan(d))
	assert_eq(d.money, 0)

func test_part_repayment() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	d.money = 300
	assert_true(BuildingSociety.repay(d, 300).ok)
	assert_eq(BuildingSociety.owed(d), 700)
	assert_false(BuildingSociety.repay(d, 500).ok, "can't pay what you haven't got")
	assert_false(BuildingSociety.repay(d, 0).ok)
	d.money = 5000
	var r := BuildingSociety.repay(d, 99999)
	assert_eq(r.paid, 700, "never takes more than is owed")

func test_savings_pay_a_little_on_the_lowest_balance() -> void:
	var d := _data(3, 5000)
	assert_true(BuildingSociety.deposit(d, "gbp", 2000))
	assert_eq(BuildingSociety.saved(d, "gbp"), 2000)
	assert_eq(d.money, 3000)
	assert_false(BuildingSociety.deposit(d, "gbp", 99999), "can't pay in what you haven't got")
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	var gain := BuildingSociety.saved(d, "gbp") - 2000
	assert_true(gain > 0 and gain <= 6, "a little: %d" % gain)
	assert_true(BuildingSociety.withdraw(d, "gbp", 500))
	assert_eq(d.money, 3500)
	assert_false(BuildingSociety.withdraw(d, "gbp", 99999))

func test_in_and_out_around_payday_earns_next_to_nothing() -> void:
	var d := _data(3, 5000)
	BuildingSociety.deposit(d, "gbp", 10)
	d.day_count += BuildingSociety.MONTH - 1
	BuildingSociety.deposit(d, "gbp", 3000)
	d.day_count += 1
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.saved(d, "gbp"), 3010, "money that was only there a day earns a day's worth, which rounds to nothing")

func test_borrowing_to_save_always_loses() -> void:
	var d := _data(3, 0)
	var lim := BuildingSociety.limit(d, "gbp")
	BuildingSociety.borrow(d, "cardiff_society", lim, 24)
	BuildingSociety.deposit(d, "gbp", lim)
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_true(BuildingSociety.net_worth(d, "gbp") < 0, "%d" % BuildingSociety.net_worth(d, "gbp"))

func test_euro_branch_uses_euros() -> void:
	var d := _data(3, 0)
	var r := BuildingSociety.borrow(d, "dublin_society", 500, 6)
	assert_true(r.ok, str(r.get("why", "")))
	assert_eq(d.euros, 500)
	assert_eq(d.money, 0)
	assert_eq(BuildingSociety.loan_cur(d), "eur")
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_true(d.euros < 500, "repayment came out of the euro purse")

func test_mum_sends_a_sub_after_the_first_stone_and_only_once() -> void:
	var d := _data(0, 50)
	d.day_count += 1
	BuildingSociety.settle(d)
	assert_true(BuildingSociety.letters_waiting(d).is_empty(), "nothing before a Stone")
	d.badges.append("b0")
	BuildingSociety.settle(d)
	assert_true("mum_sub" in BuildingSociety.letters_waiting(d))
	assert_eq(d.money, 50, "the money comes with the post, not before")
	var got := BuildingSociety.collect_letters(d)
	assert_true("mum_sub" in got)
	assert_eq(d.money, 50 + BuildingSociety.MUM_SUB)
	assert_eq(BuildingSociety.mum_owed(d), BuildingSociety.MUM_SUB)
	BuildingSociety.settle(d)
	assert_true(BuildingSociety.letters_waiting(d).is_empty(), "once only")
	assert_eq(BuildingSociety.collect_letters(d), [], "and the post is gone once collected")
	assert_true(BuildingSociety.repay_mum(d, 100).ok)
	assert_eq(BuildingSociety.mum_owed(d), BuildingSociety.MUM_SUB - 100, "no interest, ever")
	d.day_count += 400
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.mum_owed(d), BuildingSociety.MUM_SUB - 100)
	assert_true(BuildingSociety.repay_mum(d, 99999).ok)
	assert_eq(BuildingSociety.mum_owed(d), 0)
	assert_false(BuildingSociety.repay_mum(d, 5).ok, "nothing left to repay")

func test_old_saves_have_no_society_and_load_clean() -> void:
	var d := GameStateData.from_dict({"money": 10}, Dex.load_default())
	assert_false(BuildingSociety.has_loan(d))
	assert_eq(BuildingSociety.owed(d), 0)
	assert_eq(BuildingSociety.saved(d, "gbp"), 0)
	BuildingSociety.settle(d)
	var d2 := GameStateData.from_dict(JSON.parse_string(JSON.stringify(_with_loan().to_dict())), Dex.load_default())
	assert_eq(BuildingSociety.owed(d2), 1000, "a loan survives a save and a load (JSON turns ints to floats)")
	assert_eq(BuildingSociety.owed(d2) + 0, BuildingSociety.payoff(d2))

func _with_loan() -> GameStateData:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	return d

func test_statement_lists_everything() -> void:
	var d := _with_loan()
	BuildingSociety.deposit(d, "gbp", 400)
	var lines := BuildingSociety.statement(d)
	assert_true(lines.size() >= 2)
	var text := "\n".join(lines.map(func(l): return str(l)))
	assert_true(text.contains("1,000") and text.contains("400"), text)

func test_letters_come_through_the_post_box_once() -> void:
	var d := _data(3, 0)
	BuildingSociety.borrow(d, "cardiff_society", 1000, 12)
	d.money = 0
	d.day_count += BuildingSociety.MONTH
	BuildingSociety.settle(d)
	assert_eq(BuildingSociety.collect_letters(d), ["late_1"])
	assert_eq(BuildingSociety.collect_letters(d), [])

func test_nothing_prints_money() -> void:
	var r := SocietySim.table(40)
	for s in SocietySim.STRATEGIES:
		assert_true(r[s].best <= r.save_all.best + 0.0001, "%s never beats just saving: %s vs %s" % [s, r[s].best, r.save_all.best])
	assert_true(r.borrow_and_save.best < 0.0, "borrowing to save loses every time")
	assert_true(r.borrow_and_sit.best < 0.0, "so does borrowing to sit on it")
	assert_true(r.save_all.best < 0.05, "even saving everything is small beer: %s" % r.save_all.best)
