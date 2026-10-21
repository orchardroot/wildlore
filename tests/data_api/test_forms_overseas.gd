extends TestCase
## 4.2 Far and Wide, overseas regional forms (data only): every form belongs to a real species, stays inside the
## contract's limits and has an accurate one-line fact.

const PATH := "res://data/forms_overseas.json"

var dex := Dex.load_default()

func _forms() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))

func test_overseas_forms_cover_fifteen_to_twenty() -> void:
	var n := 0
	for sid in _forms():
		n += _forms()[sid].size()
	assert_true(n >= 15 and n <= 20, "15 to 20 overseas forms, got %d" % n)

func test_forms_obey_the_contract() -> void:
	var data := _forms()
	for sid in data:
		assert_true(dex.has(sid), "%s is a real species" % sid)
		for fid in data[sid]:
			var f: Dictionary = data[sid][fid]
			var tag := "%s/%s" % [sid, fid]
			assert_true(str(f.name) != "" and not f.regions.is_empty(), tag)
			for r in f.regions:
				assert_true(str(r).begins_with("overseas_"), "%s region %s" % [tag, r])
			var sum := 0
			for stat in f.stat_lean:
				assert_true(absi(int(f.stat_lean[stat])) <= 6, "%s lean within 6" % tag)
				sum += int(f.stat_lean[stat])
			assert_eq(sum, 0, "%s lean nets to zero" % tag)
			if f.has("types"):
				var base: Array = dex.get_species(sid).types
				var changed := 0
				for i in f.types.size():
					if i >= base.size() or f.types[i] != base[i]:
						changed += 1
				assert_true(changed <= 1, "%s changes at most one type" % tag)
			assert_true(str(f.fact) != "" and not ("—" in str(f.fact) or "—" in str(f.name)), "%s fact, no em-dashes" % tag)
