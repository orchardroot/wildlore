class_name Stud
extends RefCounted
## Good Stock, the shows and the purse (docs/design/2026-10-21-breeding.md, sections 4 and 7): the Breed Class at the
## County Shows, the stud fee, standing your own creature at stud and the genotype test at Roslin. Pure logic; the
## Steward's menu is story/tournament_run.gd and the boarding paddock is a Deed (data/deeds/paddock_wirral.json).
## Money can't be printed here: the fee is a sink, a stud out of your own stable pays back half of it at most, and
## only after a Breed Class win and once a real day (DailyKey); the class takes one entry a day like the others.
## Flags (this session owns the stud_* namespace):
##   stud_paid_<day>   sterling fees paid on that in-game day (Breeding writes it through pay_fee)
##   stud_out          DailyKey stamp of the last day you stood a creature at stud
##   stud_tested       [uid] of every creature Roslin has read
##   stud_uid_n        counter behind ensure_uid

const FEE_PAY := 3           # Jobs.money_for scale: a fee runs 30 pounds at no badges to 300 at ten
const STUD_OUT_SHARE := 0.5  # what standing at stud pays, as a share of the fee Dot would charge
const TEST_BASE := 500       # the genotype test: dear early, cheap late, never under TEST_FLOOR
const TEST_PER_BADGE := 40
const TEST_FLOOR := 100
const FLAG_PAID := "stud_paid_"
const FLAG_OUT := "stud_out"
const FLAG_TESTED := "stud_tested"
const FLAG_UID := "stud_uid_n"
const PEDIGREE_POINTS := 5   # per recorded generation, up to PEDIGREE_MAX
const PEDIGREE_MAX := 15

## Sterling whole pounds, keyed on badges like Jobs.money_for.
static func fee(data: GameStateData) -> int:
	return Jobs.money_for({"pay": FEE_PAY}, data.badges.size())

static func test_fee(data: GameStateData) -> int:
	return maxi(TEST_FLOOR, TEST_BASE - TEST_PER_BADGE * data.badges.size())

static func paid_on(data: GameStateData, day: int) -> int:
	var v: Variant = data.flag(FLAG_PAID + str(day))
	return int(v) if v != null else 0

## Takes `gbp` (sterling) in the local currency for a stud fee. False, and nothing taken, if you can't cover it.
static func pay_fee(data: GameStateData, gbp: int, cur: String) -> bool:
	if not Wallet.spend(data, Wallet.localise(gbp, cur), cur):
		return false
	data.set_flag(FLAG_PAID + str(data.day_count), paid_on(data, data.day_count) + gbp)
	return true

# --- standing at stud ------------------------------------------------------------------

## "" if the creature can stand at stud now, else why not (the Steward's or Dot's line).
static func stud_out_blocker(data: GameStateData, c: Creature) -> String:
	if ShowClasses.wins(data, ShowClasses.BREED) < 1:
		return "Win a Breed Class first. Nobody pays to put their ewe to a creature with no rosette."
	if not Genetics.breeds(Genetics.kindred_of(c)) or c.sex == "":
		return "%s isn't the sort anyone breeds from." % c.display_name()
	if DailyKey.done_today(data, FLAG_OUT):
		return "One engagement a day. Even the best sire needs his tea."
	return ""

## Stands the creature at stud for an NPC owner's fee; returns the sterling paid (0 if it can't).
static func stand_at_stud(data: GameStateData, c: Creature, cur: String) -> int:
	if stud_out_blocker(data, c) != "":
		return 0
	var gbp := int(round(fee(data) * STUD_OUT_SHARE))
	Wallet.earn(data, Wallet.localise(gbp, cur), cur)
	TrainerStats.earned(data, gbp)
	data.set_flag(FLAG_OUT, DailyKey.stamp(data))
	return gbp

# --- the genotype test -----------------------------------------------------------------

## A creature's identity for the Stud Book. Hands out a fresh uid if it has none (never reuses one).
static func ensure_uid(data: GameStateData, c: Creature) -> int:
	if c.uid == 0:
		var n := int(data.flag(FLAG_UID)) if data.flag(FLAG_UID) != null else 0
		data.set_flag(FLAG_UID, n + 1)
		c.uid = absi(hash("uid/%d/%d" % [data.rng_seed, n])) % 1000000000 + 1
	return c.uid

static func tested(data: GameStateData, c: Creature) -> bool:
	var v: Variant = data.flag(FLAG_TESTED)
	return c.uid != 0 and v is Array and (v as Array).has(c.uid)

## Pays Roslin to read the full genome. "" on success, else the reason.
static func genotype_test(data: GameStateData, c: Creature, cur: String) -> String:
	if not Genetics.breeds(Genetics.kindred_of(c)):
		return "There's nothing to read in this one that Roslin can use."
	ensure_uid(data, c)
	if tested(data, c):
		return "Already read, and the answer hasn't changed since."
	if not Wallet.spend(data, Wallet.localise(test_fee(data), cur), cur):
		return "That's %s for the full reading, and you're short." % Wallet.fmt(Wallet.localise(test_fee(data), cur), cur)
	var list: Array = (data.flag(FLAG_TESTED) as Array).duplicate() if data.flag(FLAG_TESTED) is Array else []
	list.append(c.uid)
	data.set_flag(FLAG_TESTED, list)
	return ""

# --- the Breed Class -------------------------------------------------------------------

## Creatures that can enter: anything in the party of a kindred that breeds. [{index, name}].
static func entrants(data: GameStateData) -> Array:
	var out := []
	for i in data.party.size():
		var c: Creature = data.party[i]
		if Genetics.breeds(Genetics.kindred_of(c)) and c.sex != "":
			out.append({"index": i, "name": c.display_name()})
	return out

## The judges' marks, 0 to 100: {coat, frame, markings, pedigree, manners, score}. Coat, frame, markings and pedigree,
## no battle; manners is a seeded 0 to 10 so a retry can't re-roll it. A caught creature scrapes a middling mark; only
## stock bred to type (a strong frame, a rare coat, a recorded pedigree) wins.
static func judge(c: Creature, seed_text: String) -> Dictionary:
	var s := Genetics.showing(c)
	var coat := 0
	if bool(s.tortie) or str(s.variant).contains("+"):
		coat = 25
	elif str(s.variant) != "":
		coat = 15
	var frame := int(round(int(s.frame) * 25.0 / 8.0))
	var marks := int(s.mark) * 10
	var depth := Genetics._height(Genetics._node(c, 3))
	var ped := mini(PEDIGREE_MAX, depth * PEDIGREE_POINTS)
	var rng := Rng.new(absi(hash("breed/%s/%s" % [seed_text, c.uid if c.uid != 0 else c.display_name()])))
	var manners := rng.roll_int(0, 10)
	return {"coat": coat, "frame": frame, "markings": marks, "pedigree": ped, "manners": manners,
		"score": clampi(coat + frame + marks + ped + manners, 0, 100)}

# --- the sim ---------------------------------------------------------------------------

## What the stud farm strategy earns per in-game day over `days`, at `badges`: breed daily (the fee), show weekly
## (a first in the Breed Class, which is generous), stand at stud daily once a rosette is won. Returns
## {gross, fees, net, per_day}. The test insists this stays under 1.5 times the plain show-day prize money and
## doesn't grow with time.
static func stud_farm(badges: int, days: int) -> Dictionary:
	var d := GameStateData.new()
	for i in badges:
		d.badges.append("b%d" % i)
	var f := fee(d)
	var gross := 0.0
	var fees := 0.0
	var won := false
	for day in range(1, days + 1):
		fees += f + (test_fee(d) if day % 30 == 0 else 0)
		if day % ShowClasses.SHOW_EVERY == 0:
			gross += ShowClasses.BREED_PRIZE[0]
			won = true
		if won:
			gross += f * STUD_OUT_SHARE
	return {"gross": gross, "fees": fees, "net": gross - fees, "per_day": (gross - fees) / maxf(1.0, days)}

## The existing main line: a first in the produce class and the sheepdog trials on each show day.
static func main_line(days: int) -> float:
	return float(ShowClasses.PRODUCE_PRIZE[0] + ShowClasses.DOG_PRIZE[0]) * floorf(days / float(ShowClasses.SHOW_EVERY)) / maxf(1.0, days)
