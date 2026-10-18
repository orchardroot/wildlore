extends TestCase
## The Keeper venues and the two finale stages are dressed as real places: their own props, a crowd whose
## lines change once you've won, and nothing in the way of the Keeper.

## zone -> [the NPC you fight, the flag that says you've won there]
const VENUES := {
	"cardiff_arena": ["keeper_rhys", "trainer_keeper_rhys"],
	"belfast_yard": ["keeper_ruairi", "trainer_keeper_ruairi"],
	"dublin_hall": ["keeper_declan", "trainer_keeper_declan"],
	"galway_docks": ["keeper_nuala", "trainer_keeper_nuala"],
	"glastonbury_tor": ["keeper_morwen", "trainer_keeper_morwen"],
	"inverness_rink": ["keeper_isla", "trainer_keeper_isla"],
	"liverpool_club": ["keeper_ray", "trainer_keeper_ray"],
	"llanberis_quarry": ["keeper_eluned", "trainer_keeper_eluned"],
	"york_minster_crypt": ["keeper_hester", "trainer_keeper_hester"],
	"stonehenge": ["champion_garside", "champion"],
	"vane_tower_top": ["vane", "game_complete"],
}

const VENUE_PROPS := ["stadium_stand", "rugby_posts", "floodlight", "puddle", "pitch_line", "gantry_crane", "ship_ribs",
	"steel_plates", "hall_stage", "tea_urn", "stacked_chairs", "currach", "lobster_pots", "harbour_arch", "fae_lantern",
	"toadstool_ring", "clootie_tree", "curling_house", "curling_stones", "brick_arch", "band_kit", "stage_light",
	"slate_stack", "slate_wagon", "crypt_arch", "candelabra", "tomb_chest", "brazier", "city_window",
	"enclosure_banner", "creature_cage"]

## Props that bring their own flickering light.
const GLOWS := {"floodlight": "floodlight_glow", "fae_lantern": "fae_glow", "stage_light": "stage_glow",
	"candelabra": "candle_glow", "brazier": "brazier_fire"}

func _npc(z: ZoneData, id: String) -> Dictionary:
	for n in z.npcs:
		if str(n.get("id", "")) == id:
			return n
	return {}

## Everyone standing in the room with `won` set or not, as blocked tiles. Story gates that have stood aside by
## the time you can fight here (the Moot's gate wardens) are left out.
func _crowd(z: ZoneData, flag: String, won: bool) -> Dictionary:
	var out := {}
	for n in z.npcs:
		if n.has("hide_if") and (str(n.hide_if) != flag or won):
			continue
		if n.has("show_if") and str(n.show_if) == flag and not won:
			continue
		out[Vector2i(int(n.x), int(n.y))] = true
	return out

func test_every_venue_prop_is_registered_and_builds() -> void:
	for name in VENUE_PROPS:
		assert_true(name in ZoneBuilder.POINT_PROPS, name + " is registered")
		assert_true(ZoneBuilder._ctor(name, 3).get_surface_count() > 0, name + " has geometry")
	for name in GLOWS:
		assert_true(ZoneBuilder._ctor(GLOWS[name], 1).get_surface_count() > 0, GLOWS[name] + " has geometry")

func test_lights_flicker() -> void:
	Meshes.materials()
	var props := []
	var x := 1
	for name in GLOWS:
		props.append({"type": name, "x": x, "y": 1})
		x += 1
	var z := ZoneData.from_dict({"id": "t", "name": "T", "kind": "interior", "rows": ["xxxxxxxx", "x||||||x", "x||||||x", "xxxxxxxx"],
		"props": props, "warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [2, 2], "weather": {}})
	var root := ZoneBuilder.build(z)
	for name in GLOWS:
		var node := root.get_node_or_null("Props_%s_0" % GLOWS[name])
		assert_true(node != null, GLOWS[name] + " is built")
		if node != null:
			assert_eq((node as GeometryInstance3D).material_override, Meshes.firelight, GLOWS[name] + " flickers")
	root.free()

func test_every_venue_is_dressed() -> void:
	for zid in VENUES:
		var z := ZoneData.load_id(zid)
		var own := z.props.filter(func(p): return str(p.get("type", "")) in VENUE_PROPS)
		assert_true(own.size() >= 3, "%s has its own venue props (%d)" % [zid, own.size()])

func test_spectators_change_their_tune_after_you_win() -> void:
	for zid in VENUES:
		var z := ZoneData.load_id(zid)
		var flag: String = VENUES[zid][1]
		var before := z.npcs.filter(func(n): return str(n.get("hide_if", "")) == flag and n.has("text"))
		var after := z.npcs.filter(func(n): return str(n.get("show_if", "")) == flag and n.has("text"))
		assert_true(before.size() >= 2, "%s has a crowd before the fight" % zid)
		assert_eq(after.size(), before.size(), "%s: every spectator has an after line" % zid)
		for n in before + after:
			assert_false(str(n.text).contains("—"), "%s/%s: no em-dashes" % [zid, n.id])
			assert_true(str(n.text).length() <= 160, "%s/%s: one line, not a speech" % [zid, n.id])

func test_nothing_stands_between_you_and_the_keeper() -> void:
	for zid in VENUES:
		var z := ZoneData.load_id(zid)
		var keeper := _npc(z, VENUES[zid][0])
		assert_false(keeper.is_empty(), zid + " has its keeper")
		var kp := Vector2i(int(keeper.x), int(keeper.y))
		for won in [false, true]:
			var blocked := _crowd(z, VENUES[zid][1], won)
			blocked.erase(kp)
			var seen := z.reachable(z.spawn, ZoneData.GATE_ABILITIES, blocked)
			var near := false
			for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
				near = near or seen.has(kp + d)
			assert_true(near, "%s: you can walk up to the keeper (won=%s)" % [zid, won])
