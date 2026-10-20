extends TestCase
## 3.1 Streets (England, Wales, Isle of Man): the original towns get local architecture from StreetsEW.

const TOWNS := ["bath", "birmingham", "buxton", "chester", "glastonbury", "keswick", "lancaster", "liverpool", "london",
	"macclesfield", "manchester", "newcastle", "nottingham", "penzance", "sheffield", "whitby", "york", "aberystwyth",
	"cardiff", "holyhead", "llanberis", "llangollen", "st_davids", "douglas"]

func test_every_style_builds_for_awkward_footprints() -> void:
	for s in StreetsEW.STYLES:
		assert_true(StreetsEW.has_style(s), s)
		for fp in [[2, 2, 0], [3, 3, 1], [6, 4, 2], [8, 5, -1]]:
			var m: Array = Meshes.building(fp[0], fp[1], s, fp[2], 11)
			assert_true(m[0] is ArrayMesh and (m[0] as ArrayMesh).get_surface_count() > 0, "%s %s" % [s, fp])
			assert_true(m[1] is ArrayMesh, s + " windows")

func test_styles_table_matches_list() -> void:
	assert_eq(StreetsEW.STYLES.size(), StreetsEW.DEFS.size())
	for s in StreetsEW.STYLES:
		assert_true(StreetsEW.DEFS.has(s), s)

func test_every_original_town_has_a_local_look() -> void:
	for t in TOWNS:
		var z: Dictionary = JsonUtil.read("res://data/zones/%s.json" % t)
		var local := 0
		for p in z.get("props", []):
			if p.get("type") == "building" and StreetsEW.has_style(str(p.get("style", ""))):
				local += 1
		assert_true(local >= 1, "%s has local street styles (%d)" % [t, local])

func test_streets_ignore_other_styles() -> void:
	assert_false(StreetsEW.has_style("terrace"))
	assert_false(StreetsEW.has_style("castle"))
