class_name FixedRng
extends Rng
## Test double. Every roll returns `f`; integer rolls return the low bound (or high with hi = true).
## Default f = 1.0: no crits, maximum damage roll, no random status procs.

var f := 1.0
var hi := false

func roll() -> float:
	return f

func roll_int(a: int, b: int) -> int:
	return b if hi else a

func roll_range(a: float, b: float) -> float:
	return a + (b - a) * f

func chance(percent: float) -> bool:
	if percent >= 100.0:
		return true
	if percent <= 0.0:
		return false
	return f * 100.0 < percent

func pick(arr: Array):
	return arr[0]
