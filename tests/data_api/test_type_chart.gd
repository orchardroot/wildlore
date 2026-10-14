extends TestCase

var chart := TypeChart.load_default()

func test_sixteen_types() -> void:
	assert_eq(chart.types.size(), 16)

func test_super_effective() -> void:
	assert_eq(chart.multiplier("hearth", "hedgerow"), 2.0)
	assert_eq(chart.multiplier("brook", "hearth"), 2.0)

func test_not_very_effective() -> void:
	assert_eq(chart.multiplier("hearth", "brook"), 0.5)

func test_no_effect() -> void:
	assert_eq(chart.multiplier("kin", "spirit"), 0.0)
	assert_eq(chart.multiplier("storm", "stone"), 0.0)

func test_unlisted_pair_is_neutral() -> void:
	assert_eq(chart.multiplier("kin", "kin"), 1.0)

func test_fae_fears_iron() -> void:
	assert_eq(chart.multiplier("iron", "fae"), 2.0)

func test_dual_types_multiply() -> void:
	assert_eq(chart.effectiveness("iron", ["fae", "frost"]), 4.0)
	assert_eq(chart.effectiveness("storm", ["brook", "stone"]), 0.0)
	assert_eq(chart.effectiveness("hearth", ["hedgerow", "brook"]), 1.0)

func test_typeless_move_is_neutral() -> void:
	assert_eq(chart.effectiveness("", ["hedgerow"]), 1.0)

func test_real_chart_is_valid() -> void:
	assert_eq(chart.validate(), [])

func test_validate_catches_unknown_type() -> void:
	var bad := TypeChart.from_dict({"types": ["a", "b"], "chart": {"a": {"se": ["zz"]}, "b": {"se": ["a"]}}})
	assert_true(bad.validate().size() > 0)

func test_validate_catches_type_with_no_weakness() -> void:
	var bad := TypeChart.from_dict({"types": ["a", "b"], "chart": {"a": {"se": ["a"]}, "b": {"se": ["a"]}}})
	assert_has(bad.validate(), "type 'b' has no weakness")

func test_xp_curves() -> void:
	assert_eq(Rules.xp_for_level("medium", 1), 0)
	assert_eq(Rules.xp_for_level("medium", 10), 1000)
	assert_eq(Rules.xp_for_level("fast", 10), 800)
	assert_eq(Rules.xp_for_level("slow", 10), 1250)
