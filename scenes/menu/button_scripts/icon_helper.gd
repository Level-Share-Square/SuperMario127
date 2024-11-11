tool
extends TextureRect

signal offset_changed

export var countdown_path: NodePath
onready var countdown: Node

export var disabled_color := Color.white
onready var parent = get_parent()

export (Array, int) var count_offsets
export var offset: Vector2 setget set_offset
func set_offset(new_value: Vector2):
	offset = new_value
	emit_signal("offset_changed")


func _ready():
	if has_node(countdown_path):
		countdown = get_node(countdown_path)
	
	parent.connect("resized", self, "update_offset")
	connect("offset_changed", self, "update_offset")
	update_offset()

func update_offset():
	self_modulate = disabled_color if parent.disabled else Color.white
	
	match parent.align:
		parent.ALIGN_CENTER:
			rect_position.x = (get_parent().rect_size.x / 2) - (rect_size.x / 2)
		parent.ALIGN_LEFT:
			rect_position.x = 0
		parent.ALIGN_RIGHT:
			rect_position.x = get_parent().rect_size.x - rect_size.x
	rect_position.x += offset.x
	
	rect_position.y = (get_parent().rect_size.y / 2) - (rect_size.y / 2)
	rect_position.y += offset.y
	
	if is_instance_valid(countdown) and countdown.count > 0:
		rect_position.x += count_offsets[ceil(countdown.count)]
