class_name Rng
extends RefCounted
## Seeded RNG wrapper so battles replay identically from a seed.

var _r := RandomNumberGenerator.new()

func _init(seed_value: int = 0) -> void:
	_r.seed = seed_value

func roll() -> float:
	return _r.randf()

func roll_int(a: int, b: int) -> int:
	return _r.randi_range(a, b)

func roll_range(a: float, b: float) -> float:
	return _r.randf_range(a, b)

func chance(percent: float) -> bool:
	if percent >= 100.0:
		return true
	if percent <= 0.0:
		return false
	return _r.randf() * 100.0 < percent

func pick(arr: Array):
	return arr[_r.randi_range(0, arr.size() - 1)]
