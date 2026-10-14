class_name ZoneData
extends RefCounted
## One zone (town, route, interior, dungeon) parsed from data/zones/<id>.json. Grid rules live here; rendering lives in ZoneBuilder.

const DIR := "res://data/zones"
## char -> [tile name, walkable]
const LEGEND := {
	".": ["grass", true], ",": ["tall_grass", true], "#": ["path", true], "=": ["road", true],
	":": ["cobbles", true], "s": ["sand", true], "f": ["flowers", true], "~": ["water", false],
	"w": ["shallow", true], "T": ["tree_oak", false], "P": ["tree_pine", false], "H": ["hedge", false],
	"W": ["drystone_wall", false], "F": ["fence", false], "R": ["rock", false], "^": ["cliff", false],
	"B": ["building", false], "D": ["door", true], "x": ["void", false], "|": ["floor_wood", true],
	"+": ["floor_tile", true], "C": ["counter", false], "L": ["ledge_south", false],
}
const WALKABLE_TILES := ["grass", "tall_grass", "path", "road", "cobbles", "sand", "flowers", "shallow", "door", "floor_wood", "floor_tile"]
const OPPOSITE := {"north": "south", "south": "north", "east": "west", "west": "east"}

var id := ""
var name := ""
var region := ""
var kind := "route"
var music := ""
var weather: Dictionary = {}
var width := 0
var height := 0
var chars: Array = []      # rows of single-char strings as written
var tiles: Array = []      # rows of tile names
var heights: Array = []    # rows of ints
var legend_extra: Dictionary = {}
var props: Array = []
var warps: Array = []
var edges: Dictionary = {}
var npcs: Array = []
var encounters: Dictionary = {}
var signs: Array = []
var spawn := Vector2i.ZERO
var parse_errors: Array = []

static func load_id(zone_id: String) -> ZoneData:
	var d = JsonUtil.read(DIR.path_join(zone_id + ".json"))
	return from_dict(d if d is Dictionary else {"id": zone_id})

static func load_all() -> Dictionary:
	var out := {}
	for path in JsonUtil.list_json(DIR):
		var d = JsonUtil.read(path)
		if d is Dictionary:
			var z := from_dict(d)
			out[z.id] = z
	return out

static func from_dict(d: Dictionary) -> ZoneData:
	var z := ZoneData.new()
	z.id = d.get("id", "")
	z.name = d.get("name", z.id)
	z.region = d.get("region", "")
	z.kind = d.get("kind", "route")
	z.music = d.get("music", "")
	z.weather = d.get("weather", {})
	z.legend_extra = d.get("legend_extra", {})
	z.props = d.get("props", [])
	z.warps = d.get("warps", [])
	z.edges = d.get("edges", {})
	z.npcs = d.get("npcs", [])
	z.encounters = d.get("encounters", {})
	z.signs = d.get("signs", [])
	var sp: Array = d.get("spawn", [0, 0])
	z.spawn = Vector2i(int(sp[0]), int(sp[1]))
	var rows: Array = d.get("rows", [])
	z.height = rows.size()
	z.width = 0
	for r in rows:
		z.width = maxi(z.width, str(r).length())
	for y in rows.size():
		var row: String = rows[y]
		if row.length() != z.width:
			z.parse_errors.append("row %d is ragged (%d wide, expected %d)" % [y, row.length(), z.width])
		var crow := []
		var trow := []
		for x in z.width:
			var c := row[x] if x < row.length() else "x"
			crow.append(c)
			var t := z._tile_for_char(c)
			if t == "":
				z.parse_errors.append("unknown tile char '%s' at %d,%d" % [c, x, y])
				t = "void"
			trow.append(t)
		z.chars.append(crow)
		z.tiles.append(trow)
	var hrows: Array = d.get("heights", [])
	if not hrows.is_empty() and (hrows.size() != z.height):
		z.parse_errors.append("heights has %d rows, expected %d" % [hrows.size(), z.height])
	for y in z.height:
		var hrow := []
		var src: String = hrows[y] if y < hrows.size() else ""
		if src != "" and src.length() != z.width:
			z.parse_errors.append("heights row %d is %d wide, expected %d" % [y, src.length(), z.width])
		for x in z.width:
			hrow.append(int(src[x]) if x < src.length() and src[x].is_valid_int() else int(d.get("ground_height", 0)))
		z.heights.append(hrow)
	return z

func _tile_for_char(c: String) -> String:
	if legend_extra.has(c):
		return str(legend_extra[c].get("tile", ""))
	if LEGEND.has(c):
		return LEGEND[c][0]
	return ""

func in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < width and p.y < height

func tile_at(p: Vector2i) -> String:
	return tiles[p.y][p.x] if in_bounds(p) else ""

func char_at(p: Vector2i) -> String:
	return chars[p.y][p.x] if in_bounds(p) else ""

func height_at(p: Vector2i) -> int:
	return heights[p.y][p.x] if in_bounds(p) else 0

## Can the player stand on p, arriving by moving `from_dir`? NPC occupancy is the overworld's job.
func walkable(p: Vector2i, from_dir := Vector2i.ZERO) -> bool:
	if not in_bounds(p):
		return false
	var t := tile_at(p)
	if t == "ledge_south":
		return from_dir == Vector2i(0, 1)
	if t not in WALKABLE_TILES:
		return false
	if from_dir != Vector2i.ZERO:
		var prev := p - from_dir
		if in_bounds(prev) and absi(height_at(prev) - height_at(p)) > 1:
			return false
	return true

## Where a ledge hop lands: the first walkable tile south of the ledge.
func ledge_landing(p: Vector2i) -> Vector2i:
	var q := p + Vector2i(0, 1)
	return q

func warp_at(p: Vector2i) -> Dictionary:
	for w in warps:
		if int(w.x) == p.x and int(w.y) == p.y:
			return w
	return {}

func sign_at(p: Vector2i) -> Dictionary:
	for s in signs:
		if int(s.x) == p.x and int(s.y) == p.y:
			return s
	return {}

## Arrival tile when walking off `side` of this zone into its neighbour.
func edge_arrival(side: String, p: Vector2i, target: ZoneData) -> Vector2i:
	var off := int(edges[side].get("offset", 0))
	match side:
		"north":
			return Vector2i(p.x + off, target.height - 1)
		"south":
			return Vector2i(p.x + off, 0)
		"west":
			return Vector2i(target.width - 1, p.y + off)
		_:
			return Vector2i(0, p.y + off)

func validate(all: Dictionary) -> Array:
	var e := parse_errors.duplicate()
	var tag := "zone %s: " % id
	for i in e.size():
		e[i] = tag + e[i]
	if not walkable(spawn):
		e.append(tag + "spawn %s is not walkable" % spawn)
	for w in warps:
		var target: String = w.get("to", "")
		if not all.has(target):
			e.append(tag + "warp at %d,%d goes to unknown zone '%s'" % [int(w.x), int(w.y), target])
		elif not all[target].walkable(Vector2i(int(w.tx), int(w.ty))):
			e.append(tag + "warp arrival %d,%d in '%s' is not walkable" % [int(w.tx), int(w.ty), target])
	for side in edges:
		var target: String = edges[side].get("to", "")
		if side not in OPPOSITE:
			e.append(tag + "unknown edge '%s'" % side)
		elif not all.has(target):
			e.append(tag + "%s edge goes to unknown zone '%s'" % [side, target])
		elif not all[target].edges.has(OPPOSITE[side]) or all[target].edges[OPPOSITE[side]].get("to") != id:
			e.append(tag + "%s edge to '%s' has no %s edge back" % [side, target, OPPOSITE[side]])
	for s in signs:
		if not in_bounds(Vector2i(int(s.x), int(s.y))):
			e.append(tag + "sign at %d,%d is out of bounds" % [int(s.x), int(s.y)])
	for n in npcs:
		if not walkable(Vector2i(int(n.x), int(n.y))):
			e.append(tag + "npc '%s' stands on an unwalkable tile" % n.get("id", "?"))
	var covered := {}
	for p in props:
		if p.get("type") == "building":
			for yy in range(int(p.y), int(p.y) + int(p.h)):
				for xx in range(int(p.x), int(p.x) + int(p.w)):
					covered[Vector2i(xx, yy)] = true
					if tile_at(Vector2i(xx, yy)) not in ["building", "door"]:
						e.append(tag + "building '%s' covers %d,%d which is not B or D" % [p.get("label", "?"), xx, yy])
	for y in height:
		for x in width:
			if tiles[y][x] == "building" and not covered.has(Vector2i(x, y)):
				e.append(tag + "B at %d,%d is not covered by a building prop" % [x, y])
	return e
