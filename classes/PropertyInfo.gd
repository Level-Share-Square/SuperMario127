class_name PropertyInfo
extends Resource

var hint: String

# for floats, ints, and vector2s
var min_value = -1
var max_value = -1
var step: float = 1
var prefix: Array = ["", ""]
var suffix: Array = ["", ""]
var enforce_step: bool = false

func _init(_hint: String, _step = 1, _min_value = -INF, _max_value = INF, _prefix = ["", ""], _suffix = ["", ""], _enforce_step = false):
	hint = _hint
	step = _step
	min_value = _min_value
	max_value = _max_value
	prefix = _prefix
	suffix = _suffix
	enforce_step = _enforce_step
