class_name Coverage
extends RefCounted
## Content coverage rules: every species a dex habitat places in a built zone must be catchable there or
## somewhere (legends excepted: they come from story `legend` commands), and every route with tall grass or
## deep water offers at least MIN_ROUTE_ENTRIES encounters.

const MIN_ROUTE_ENTRIES := 6

## habitats: species id -> zone ids (defaults to each species' dex "habitat"); passed in for tests.
static func check(dex: Dex, zones: Dictionary, habitats := {}) -> Array:
	var errors := []
	var catchable := {}
	for zid in zones:
		for kind in zones[zid].encounters:
			for e in zones[zid].encounters[kind]:
				catchable[str(e.get("species", ""))] = true
	var hab := habitats
	if hab.is_empty():
		for id in dex.ids():
			hab[id] = dex.get_species(id).get("habitat", [])
	for id in hab:
		var places: Array = hab[id]
		if places.is_empty() or catchable.has(id):
			continue
		var sp := dex.get_species(id)
		if int(sp.get("catch_rate", 45)) <= 3:
			continue  # legends
		if places.all(func(z): return zones.has(z) and not zones[z].stub):
			errors.append("species %s lives in %s but no encounter table has it" % [id, ", ".join(places)])
	for zid in zones:
		var z: ZoneData = zones[zid]
		if z.kind != "route" or z.id == "testbed":
			continue
		var wild := false
		for y in z.height:
			for x in z.width:
				if z.tiles[y][x] in ["tall_grass", "deep_water"]:
					wild = true
		var n := 0
		for kind in z.encounters:
			n += z.encounters[kind].size()
		if wild and n < MIN_ROUTE_ENTRIES:
			errors.append("route %s has only %d encounter entries (needs %d)" % [zid, n, MIN_ROUTE_ENTRIES])
	return errors
