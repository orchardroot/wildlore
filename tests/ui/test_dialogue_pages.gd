extends TestCase
## Long dialogue never runs off the bottom of the box: it's split into pages that each fit.

func _fits(n: int) -> Callable:
	return func(s: String) -> bool: return s.length() <= n

func test_short_text_is_one_page() -> void:
	assert_eq(DialogueBox.paginate("Hello there.", _fits(40)), ["Hello there."])

func test_long_text_splits_at_sentences_and_every_page_fits() -> void:
	var t := "The first sentence is here. The second one follows on. A third, a little longer, closes it all off nicely."
	var pages := DialogueBox.paginate(t, _fits(60))
	assert_true(pages.size() >= 2)
	for p in pages:
		assert_true(p.length() <= 60, p)
	assert_eq(" ".join(pages), t, "nothing lost or reordered")
	assert_true(pages[0].ends_with("."), "breaks at a sentence end where it can")

func test_a_single_huge_sentence_still_splits_by_words() -> void:
	var t := "word ".repeat(40).strip_edges()
	var pages := DialogueBox.paginate(t, _fits(30))
	for p in pages:
		assert_true(p.length() <= 30)
	assert_eq(" ".join(pages), t)
