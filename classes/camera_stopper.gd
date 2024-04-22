class_name CameraStopper
extends Area2D

var top_bound
var bottom_bound 
var left_bound
var right_bound 
var editor_rect

onready var shape = $CollisionShape2D

func _ready():
	set_size(shape.shape.extents)
	set_collision_layer_bit(11, true)
	
	if get_tree().get_current_scene().mode != 0:
		editor_rect = ReferenceRect.new()
		editor_rect.rect_size = get_child(0).shape.extents * 2
		editor_rect.border_color = Color.aqua
		editor_rect.border_width = 2.0
		editor_rect.editor_only = false
		editor_rect.mouse_filter = 2
		self.add_child(editor_rect)

func _process(_delta):
	if get_tree().get_current_scene().mode != 0:
		editor_rect.rect_size = get_child(0).shape.extents * 2
		editor_rect.rect_position.x = -editor_rect.rect_size.x / 2
		editor_rect.rect_position.y = -editor_rect.rect_size.y / 2

		
func set_size(size):
	top_bound = global_transform.xform(Vector2(0, -size.y))
	bottom_bound = global_transform.xform(Vector2(0, size.y))
	left_bound = global_transform.xform(Vector2(-size.x, 0))
	right_bound = global_transform.xform(Vector2(size.x, 0))
