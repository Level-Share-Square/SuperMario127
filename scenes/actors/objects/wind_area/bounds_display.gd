extends Area2D

var editor_rect

onready var shape = $CollisionShape2D

func _ready():	
	if get_tree().get_current_scene().mode != 0:
		editor_rect = ReferenceRect.new()
		editor_rect.rect_size = shape.shape.extents * 2
		editor_rect.border_color = Color.aqua
		editor_rect.border_width = 2.0
		editor_rect.editor_only = false
		editor_rect.mouse_filter = 2
		editor_rect.rect_position = Vector2(shape.position.x-shape.shape.extents.x, shape.position.y-shape.shape.extents.y)
		self.add_child(editor_rect)

func _process(_delta):
	if get_tree().get_current_scene().mode != 0:
		editor_rect.rect_size = shape.shape.extents * 2
		editor_rect.rect_position = Vector2(shape.position.x-shape.shape.extents.x, shape.position.y-shape.shape.extents.y)
