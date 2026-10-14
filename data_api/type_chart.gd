class_name TypeChart
extends RefCounted
## Type effectiveness lookup built from data/types.json.

const DEFAULT_PATH := "res://data/types.json"

var types: Array = []
var _chart: Dictionary = {}  # attacker -> {"se": [...], "nve": [...], "none": [...]}

static func load_default() -> TypeChart:
	var d = JsonUtil.read(DEFAULT_PATH)
	return from_dict(d if d is Dictionary else {})

static func from_dict(d: Dictionary) -> TypeChart:
	var tc := TypeChart.new()
	tc.types = d.get("types", [])
	tc._chart = d.get("chart", {})
	return tc

func multiplier(attacker: String, defender: String) -> float:
	var row: Dictionary = _chart.get(attacker, {})
	if defender in row.get("none", []):
		return 0.0
	if defender in row.get("se", []):
		return 2.0
	if defender in row.get("nve", []):
		return 0.5
	return 1.0

func effectiveness(attacker: String, defender_types: Array) -> float:
	var m := 1.0
	for t in defender_types:
		m *= multiplier(attacker, t)
	return m

func validate() -> Array:
	var errors := []
	var weak := {}
	for atk in _chart:
		if atk not in types:
			errors.append("chart row for unknown type '%s'" % atk)
		var row: Dictionary = _chart[atk]
		for key in ["se", "nve", "none"]:
			for t in row.get(key, []):
				if t not in types:
					errors.append("%s.%s lists unknown type '%s'" % [atk, key, t])
		for t in row.get("se", []):
			weak[t] = true
		if row.get("se", []).is_empty() and atk != "kin":
			errors.append("type '%s' has no super-effective target" % atk)
	for t in types:
		if not weak.has(t):
			errors.append("type '%s' has no weakness" % t)
	return errors
