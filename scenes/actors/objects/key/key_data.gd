extends Resource
class_name KeyData

export var tag: String
export var color: Color
export var visible: bool

func _init(_tag: String = "", _color := Color.yellow, _visible: bool = true):
	tag = _tag
	color = _color
	visible = _visible

func is_equal(other: KeyData):
	if (tag == other.tag and
		color == other.color and
		visible == other.visible):
			return true
	return false
