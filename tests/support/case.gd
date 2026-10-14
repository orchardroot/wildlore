class_name TestCase
extends RefCounted
## Base class for tests. Assertions report to the runner and never abort the test.

var runner

func fail(msg: String) -> void:
	runner.fail(msg)

func assert_eq(actual, expected, msg := "") -> void:
	if not _comparable(actual, expected):
		fail("%s expected <%s> (%s) got <%s> (%s)" % [msg, str(expected), type_string(typeof(expected)), str(actual), type_string(typeof(actual))])
	elif actual != expected:
		fail("%s expected <%s> got <%s>" % [msg, str(expected), str(actual)])

func assert_true(cond: bool, msg := "") -> void:
	if not cond:
		fail("%s expected true" % msg)

func assert_false(cond: bool, msg := "") -> void:
	if cond:
		fail("%s expected false" % msg)

func assert_near(actual: float, expected: float, eps := 0.0001, msg := "") -> void:
	if absf(actual - expected) > eps:
		fail("%s expected ~%s got %s" % [msg, str(expected), str(actual)])

func assert_has(container, item, msg := "") -> void:
	if not (item in container):
		fail("%s expected %s to contain %s" % [msg, str(container), str(item)])

func _comparable(a, b) -> bool:
	var ta := typeof(a)
	var tb := typeof(b)
	if ta == tb:
		return true
	var nums := [TYPE_INT, TYPE_FLOAT]
	var strs := [TYPE_STRING, TYPE_STRING_NAME]
	return (ta in nums and tb in nums) or (ta in strs and tb in strs)
