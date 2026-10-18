extends TestCase
## The envelope over the post boxes: there while a postcard waits, gone once it's collected.

func _zone() -> ZoneData:
	return ZoneData.from_dict({"id": "pbz", "kind": "town", "rows": [".....", ".....", "....."],
		"props": [{"type": "post_box", "x": 1, "y": 1}, {"type": "post_box", "x": 3, "y": 1}, {"type": "bench", "x": 2, "y": 2}]})

func _waiting_data() -> GameStateData:
	var d := GameStateData.new()
	var first: Dictionary = Postcards.cards()[0]
	d.set_flag(str(first.after), true)
	return d

func test_an_envelope_over_every_post_box_while_post_waits() -> void:
	var node := Node3D.new()
	PostBox.dress(_zone(), node, _waiting_data())
	var root := node.get_node_or_null(PostBox.NODE)
	assert_true(root != null, "envelopes added")
	assert_eq(root.get_child_count(), 2, "one per post box, none on the bench")
	assert_true(root.get_node("E_1_1").visible and root.get_node("E_3_1").visible, "shown while a card waits")
	assert_true(root.get_node("E_1_1").position.y > 1.2, "above the cap")
	PostBox.show_waiting(node, false)
	assert_false(root.get_node("E_1_1").visible, "hidden once collected")
	node.free()

func test_no_envelope_without_post() -> void:
	var node := Node3D.new()
	PostBox.dress(_zone(), node, GameStateData.new())
	assert_false(node.get_node(PostBox.NODE + "/E_1_1").visible)
	node.free()

func test_no_post_boxes_no_node() -> void:
	var node := Node3D.new()
	PostBox.dress(ZoneData.from_dict({"id": "x", "kind": "town", "rows": ["..."]}), node, _waiting_data())
	assert_eq(node.get_child_count(), 0)
	node.free()

func test_envelope_texture_is_drawn_once() -> void:
	var t := PostBox.texture()
	assert_true(t != null and t.get_width() > 64)
	assert_true(PostBox.texture() == t, "cached")

func test_most_towns_have_a_post_box() -> void:
	var n := 0
	for zid in ZoneData.load_all():
		if not Postcards.post_boxes(ZoneData.load_id(zid)).is_empty():
			n += 1
	assert_true(n >= 30, "post boxes in %d zones" % n)
