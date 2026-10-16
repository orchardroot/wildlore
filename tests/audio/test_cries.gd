extends TestCase
## Creature cries: synthesised per species (seeded by its id, shaped by its types and size), the same every time,
## different for every species, and as loud as the other sound effects (see tools/audio/loudness.gd).

const Loud := preload("res://tools/audio/loudness.gd")

func _sp(id: String) -> Dictionary:
	return Fixtures.dex().get_species(id)

func test_a_cry_is_the_same_every_time() -> void:
	for id in ["spikkin", "gritling", "bran", "nessie"]:
		var a := Cries.render(_sp(id))
		var b := Cries.render(_sp(id))
		assert_true(a.size() > 0, id + " renders")
		assert_eq(a, b, id + " renders the same twice")
		assert_eq(Cries.recipe(_sp(id)), Cries.recipe(_sp(id)), id + " recipe")

func test_every_species_has_its_own_cry() -> void:
	var seen := {}
	for id in Fixtures.dex().ids():
		var key := str(Cries.recipe(_sp(id)))
		assert_false(seen.has(key), "%s sounds just like %s" % [id, seen.get(key, "")])
		seen[key] = id
	assert_true(seen.size() >= 200, "all species: %d" % seen.size())

func test_types_and_size_shape_the_cry() -> void:
	var small_hedge := Cries.recipe(_sp("spikkin"))
	var big_stone := Cries.recipe(_sp("quarrion"))
	var gale := Cries.recipe(_sp("stoopfalcon"))
	assert_eq(small_hedge.timbre, "chirp", "hedgerow chirps")
	assert_eq(big_stone.timbre, "rumble", "stone rumbles")
	assert_eq(gale.timbre, "whistle", "gale whistles")
	assert_true(float(big_stone.hz) < float(small_hedge.hz) * 0.5, "big stone is much lower than a small hedgerow chirp")
	assert_true(float(big_stone.secs) > float(small_hedge.secs), "and longer")
	# an evolved form is bigger and lower than its first stage
	assert_true(float(Cries.recipe(_sp("thornsow")).hz) < float(Cries.recipe(_sp("spikkin")).hz), "Thornsow lower than Spikkin")

func test_cries_are_short_and_sit_with_the_sfx() -> void:
	var sfx: Array = []
	for id in Loud.ids_in("res://audio/sfx"):
		sfx.append(Loud.measure("res://audio/sfx/%s.wav" % id)["rms"])
	var med := Loud.median(sfx)
	for id in Fixtures.dex().ids():
		var buf := Cries.render(_sp(id))
		var secs := buf.size() / float(Cries.SR)
		assert_true(secs >= 0.2 and secs <= 1.0, "%s lasts %.2f s" % [id, secs])
		var pk := 0.0
		for v in buf:
			pk = maxf(pk, absf(v))
		var rms := Loud.db(Loud.rms_of(buf))
		assert_true(absf(rms - med) <= 3.0, "%s rms %.2f dB vs sfx median %.2f" % [id, rms, med])
		assert_true(Loud.db(pk) <= -1.0, "%s peak %.2f dBFS" % [id, Loud.db(pk)])

func test_streams_are_cached() -> void:
	Cries.clear_cache()
	var a := Cries.stream_for(_sp("spikkin"))
	assert_true(a is AudioStreamWAV)
	assert_true(Cries.stream_for(_sp("spikkin")) == a, "second ask is the cached stream")
	assert_true(Cries.stream_for({}) == null, "no species, no cry")
