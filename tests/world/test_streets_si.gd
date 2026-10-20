extends TestCase
## Wave 31 A2: the original Scotland, Ireland and Northern Ireland towns get local street architecture.

const TOWNS := ["aberdeen", "cairnryan", "edinburgh", "fort_william", "glasgow", "inverness", "kirkwall", "portree",
	"belfast", "bushmills", "derry", "cork", "dingle", "dublin", "galway", "kilkenny", "newgrange", "sligo"]
## Looks a town may wear: the new styles plus the Irish shopfront and thatch cottage that already existed.
const LOCAL := ["edinburgh_tenement", "glasgow_tenement", "aberdeen_granite", "orkney_flagstone", "highland_sandstone",
	"harled_cottage", "harbour_row", "dublin_georgian", "ulster_terrace", "kilkenny_limestone", "irish_shopfront", "thatch_cottage"]

func test_new_styles_build_at_every_size_and_door() -> void:
	for style in StreetsSI.STYLES:
		assert_true(style in Landmarks.SPECIAL, style)
		for size in [Vector2i(3, 3), Vector2i(4, 4), Vector2i(7, 4), Vector2i(12, 6)]:
			for door in [-1, 0, size.x - 1, size.x / 2]:
				var parts: Array = Meshes.building(size.x, size.y, style, door, 11 + door)
				assert_true((parts[0] as ArrayMesh).get_surface_count() > 0, "%s %s door %d" % [style, size, door])
				assert_true((parts[1] as ArrayMesh).get_surface_count() > 0, "%s %s windows" % [style, size])

func test_chimneys_stay_over_the_footprint() -> void:
	for style in StreetsSI.STYLES:
		var parts: Array = Meshes.building(8, 4, style, 2, 5)
		for c in (parts[2] as PackedVector3Array):
			assert_true(c.x >= -0.5 and c.x <= 8.5 and c.z >= 0.0 and c.z <= 4.0, "%s chimney %s" % [style, c])

func test_each_town_wears_local_styles() -> void:
	for t in TOWNS:
		var local := 0
		var generic := 0
		for p in ZoneData.load_id(t).props:
			if str(p.get("type", "")) != "building":
				continue
			var s := str(p.get("style", ""))
			if s in LOCAL:
				local += 1
			elif s in ["terrace", "red_brick", "white_render", "cream_render", "slate_cottage"]:
				generic += 1
		assert_true(local >= 3, "%s has %d local buildings" % [t, local])
		assert_true(generic <= 2, "%s still has %d generic buildings" % [t, generic])
