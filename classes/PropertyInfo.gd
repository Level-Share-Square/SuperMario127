class_name PropertyInfo
extends Resource

var hint: String

# for floats, ints, and vector2s
var min_value = -1
var max_value = -1
var step = 1

func _init(_hint: String, _min_value = -1, _max_value = 1, _step = 1):
	hint = _hint
	min_value = _min_value
	max_value = _max_value
	step = _step
