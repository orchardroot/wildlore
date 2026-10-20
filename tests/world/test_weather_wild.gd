extends TestCase

const TYPES := {"a": ["brook"], "b": ["kin"], "c": ["spirit", "fae"], "d": ["frost"], "e": ["hedgerow"]}

func _list() -> Array:
	return ["a", "b", "c", "d", "e"].map(func(s): return {"species": s, "weight": 10})

func _w(list: Array, id: String) -> float:
	for e in list:
		if e.species == id:
			return float(e.weight)
	return -1.0

func _types(id: String) -> Array:
	return TYPES.get(id, [])

func test_rain_favours_water() -> void:
	var l := WeatherWild.shift(_list(), "downpour", _types)
	assert_eq(_w(l, "a"), 25.0)
	assert_eq(_w(l, "b"), 10.0)

func test_fog_frost_and_sun() -> void:
	assert_eq(_w(WeatherWild.shift(_list(), "fog", _types), "c"), 25.0)
	assert_eq(_w(WeatherWild.shift(_list(), "frost", _types), "d"), 25.0)
	assert_eq(_w(WeatherWild.shift(_list(), "sunshine", _types), "e"), 25.0)

func test_clear_and_unmatched_change_nothing() -> void:
	var src := _list()
	assert_eq(WeatherWild.shift(src, "clear", _types), src)
	assert_eq(_w(src, "a"), 10.0, "the zone's own table is untouched")
	var none := [{"species": "b", "weight": 10}]
	assert_eq(WeatherWild.shift(none, "downpour", _types), none)

func test_real_zone_table_leans_wet_in_rain() -> void:
	var z := ZoneData.from_dict({"id": "w", "rows": [",,,"], "spawn": [1, 0], "encounters": {"grass": [
		{"species": "spikkin", "min": 2, "max": 4, "weight": 30}, {"species": "afanc", "min": 5, "max": 5, "weight": 30}]}})
	var dry := Encounters.candidates(z, "grass", "day", "clear")
	var wet := Encounters.candidates(z, "grass", "day", "downpour")
	assert_eq(dry.size(), wet.size())
	assert_eq(_w(dry, "afanc"), 30.0)
	assert_eq(_w(wet, "afanc"), 75.0, "afanc is a brook type")

func test_battle_intro_and_radio_name_the_weather() -> void:
	assert_eq(Weather.intro_line("clear"), "")
	assert_true(Weather.intro_line("downpour").contains("Brook"))
	assert_true(Weather.intro_line("fog").contains("less likely"))
	var o := Forecast.outlook("downpour", 150, {"downpour": 30, "clear": 50, "fog": 20})
	assert_true(o[0].contains("Wet weather"))
	assert_true(o[1].contains("about 3 hours") and o[1].contains("clear skies"))
	assert_eq(Forecast.outlook("clear", -1, {}), [])
