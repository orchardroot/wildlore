extends TestCase
## Overseas towns fly the Union flag, never a UK nation's, and their wild tables only hold species that live there.

const UNION := 6
const SEALS := ["pupplash", "selklet", "greyhaul"]
const PUFFINS := ["puffling", "clownbill"]
const PENGUIN_REGIONS := ["overseas_falklands", "overseas_south_georgia", "overseas_antarctic", "overseas_tristan"]
const PUFFIN_REGIONS := ["channel_islands"]
const SEALLESS := ["overseas_bermuda", "overseas_anguilla", "overseas_bvi", "overseas_cayman", "overseas_montserrat",
	"overseas_turks_caicos", "overseas_ascension", "overseas_st_helena", "overseas_biot", "overseas_pitcairn"]

func _far(z: ZoneData) -> bool:
	return z.region.begins_with("overseas_") or z.region == "channel_islands"

func _species(z: ZoneData) -> Array:
	var out := []
	for kind in z.encounters:
		for e in z.encounters[kind]:
			out.append(str(e.species))
	return out

func test_no_overseas_flagpole_flies_a_uk_flag() -> void:
	var all := ZoneData.load_all()
	var towns := {}
	for id in all:
		if _far(all[id]):
			towns[id] = true
	for id in all:  # interiors keep no region of their own: follow the warps out
		var z: ZoneData = all[id]
		if z.region != "":
			continue
		for w in z.warps:
			if towns.has(str(w.to)) and not z.props.is_empty():
				towns[id] = true
	var poles := 0
	for id in towns:
		for p in all[id].props:
			if p.type == "flagpole":
				poles += 1
				assert_eq(int(p.get("variant", 0)), UNION, "%s flies the Union flag" % id)
	assert_true(poles > 0)
	for r in ["overseas_bermuda", "overseas_gibraltar", "channel_islands"]:
		assert_eq(Seasonal.NATION_FLAG.get(Calendar.nation_for_region(r), UNION), UNION, r)

func test_penguins_and_puffins_only_where_they_live() -> void:
	var all := ZoneData.load_all()
	for id in all:
		var z: ZoneData = all[id]
		if not _far(z):
			continue
		for s in _species(z):
			if s in PUFFINS:
				assert_true(z.region in PUFFIN_REGIONS, "%s has %s" % [id, s])
			if s in ["emperyn", "downlet", "kingwalker", "oakling", "hopperlet"]:
				assert_true(z.region in PENGUIN_REGIONS, "%s has %s" % [id, s])
			if s in SEALS:
				assert_false(z.region in SEALLESS, "%s has %s" % [id, s])

func test_bermuda_and_the_caribbean_use_local_wildlife() -> void:
	var z: ZoneData = ZoneData.load_all()["bermuda"]
	for s in ["puffling", "pupplash", "selklet"]:
		assert_false(s in _species(z), s)
	assert_true("cahowl" in _species(z))
