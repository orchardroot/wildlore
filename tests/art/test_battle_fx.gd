extends TestCase
## 2.1 battle FX: templates by move category and effect, and the spark pool that stays bounded.

func _move(cat: String, type_id: String, eff: Dictionary) -> Dictionary:
	return {"id": "x", "category": cat, "type": type_id, "effect": eff}

func test_templates_by_category_and_effect() -> void:
	assert_eq(BattleFX.template_for({}), "lunge", "unknown move: the old generic lunge")
	assert_eq(BattleFX.template_for(_move("physical", "kin", {"id": "none"})), "lunge")
	assert_eq(BattleFX.template_for(_move("physical", "bog", {"id": "drain", "frac": 50})), "lunge")
	assert_eq(BattleFX.template_for(_move("special", "brook", {"id": "none"})), "projectile")
	assert_eq(BattleFX.template_for(_move("special", "storm", {"id": "none"})), "beam")
	assert_eq(BattleFX.template_for(_move("special", "storm", {"id": "set_weather", "weather": "downpour"})), "beam", "a weather-calling hit still hits")
	assert_eq(BattleFX.template_for(_move("status", "brook", {"id": "set_weather", "weather": "drizzle", "target": "self"})), "weather")
	assert_eq(BattleFX.template_for(_move("status", "gale", {"id": "stat", "target": "foe", "stat": "acc", "stages": -1})), "cloud")
	assert_eq(BattleFX.template_for(_move("status", "tide", {"id": "status", "status": "soaked"})), "cloud")
	assert_eq(BattleFX.template_for(_move("status", "brawn", {"id": "stat", "target": "self", "stat": "atk", "stages": 2})), "aura")
	assert_eq(BattleFX.template_for(_move("status", "hedgerow", {"id": "heal_self"})), "aura")
	assert_eq(BattleFX.template_for(_move("status", "kin", {"id": "protect", "target": "self"})), "aura")

func test_every_real_move_gets_a_template() -> void:
	var seen := {}
	for f in DirAccess.get_files_at("res://data/moves"):
		if f.ends_with(".json"):
			for m in JSON.parse_string(FileAccess.get_file_as_string("res://data/moves/" + f)):
				seen[BattleFX.template_for(m)] = true
	for t in ["lunge", "projectile", "beam", "cloud", "aura", "weather"]:
		assert_true(seen.has(t), "some move plays " + t)

func test_every_battle_weather_has_a_look() -> void:
	for w in Weather.DAMAGE.keys() + ["fog", "clear"]:
		assert_true(BattleFX.WEATHER_LOOK.has(w), w + " has a flash and a sky tint")

func test_spark_pool_is_bounded_and_reused() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var dio := Diorama.new()
	tree.root.add_child(dio)
	var fx := BattleFX.new()
	tree.root.add_child(fx)
	fx.dio = dio
	await tree.process_frame
	var before := dio.get_child_count()
	for i in 30:
		fx.burst(Vector3(0, 1, 0), Color.RED, 20)
	assert_eq(fx.pool_size(), BattleFX.POOL_MAX, "the pool stops growing at its cap")
	assert_eq(dio.get_child_count() - before, BattleFX.POOL_MAX, "no node per spark beyond the cap")
	assert_eq(fx.live_sparks(), BattleFX.POOL_MAX)
	fx._process(5.0)  # everything has run its life
	assert_eq(fx.live_sparks(), 0, "spent sparks go back to the pool")
	fx.burst(Vector3(0, 1, 0), Color.RED, 20)
	assert_eq(dio.get_child_count() - before, BattleFX.POOL_MAX, "a new burst reuses the pool")
	assert_eq(fx.live_sparks(), 20)
	dio.free()
	fx.free()
