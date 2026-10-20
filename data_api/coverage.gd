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
		if bool(sp.get("legend", false)):
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

const DEV_ZONES := ["testbed", "testbed_house", "mesh_gallery"]

## Every zone must be reachable from Macclesfield through edges, warps, ferries or story warps
## (`script_warps`: zone id -> zone ids its dialogue scripts can warp to). Catches caves with no way in.
static func reachability(zones: Dictionary, ferries: Dictionary, script_warps: Dictionary) -> Array:
	var seen := {"macclesfield": true}
	var queue := ["macclesfield"]
	if zones.has("macc_home"):
		seen["macc_home"] = true
		queue.append("macc_home")
	# the overseas territories are reached by air from the registry (data/overseas/<territory>.json), not through the map
	for path in JsonUtil.list_json("res://data/overseas"):
		var reg: Variant = JsonUtil.read(path)
		var arrive := str(reg.get("arrival", {}).get("zone", "")) if reg is Dictionary else ""
		if arrive != "" and not seen.has(arrive):
			seen[arrive] = true
			queue.append(arrive)
	while not queue.is_empty():
		var zid: String = queue.pop_front()
		if not zones.has(zid):
			continue
		var z: ZoneData = zones[zid]
		var next := []
		for side in z.edges:
			next.append(str(z.edges[side].get("to", "")))
		for w in z.warps:
			next.append(str(w.get("to", "")))
		if not z.ferry.is_empty():
			var r: Dictionary = ferries.get(str(z.ferry.get("route", "")), {})
			next.append(str(r.get("a", "")))
			next.append(str(r.get("b", "")))
		next.append_array(script_warps.get(zid, []))
		for n in next:
			if n != "" and not seen.has(n):
				seen[n] = true
				queue.append(n)
	var errors := []
	for zid in zones:
		if not seen.has(zid) and zid not in DEV_ZONES and not zones[zid].stub:
			errors.append("zone %s can't be reached from Macclesfield" % zid)
	return errors

## Zone ids each zone's dialogue can warp to (story warps count as ways in).
static func script_warp_targets() -> Dictionary:
	var out := {}
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if not f.ends_with(".json"):
			continue
		var zid := f.get_basename()
		var text := FileAccess.get_file_as_string("res://data/dialogue/" + f)
		var rx := RegEx.create_from_string('"do":\\s*"warp"[^}]*?"zone":\\s*"([a-z0-9_]+)"')
		for m in rx.search_all(text):
			if not out.has(zid):
				out[zid] = []
			out[zid].append(m.get_string(1))
	return out
