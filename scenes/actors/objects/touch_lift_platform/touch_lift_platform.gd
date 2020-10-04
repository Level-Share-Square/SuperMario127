extends Node2D

onready var sprite = $Sprite
onready var recolor_sprite = $SpriteRecolor
onready var floor_touch_area = $FloorTouchArea

onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var area_collision_shape = $FloorTouchArea/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

var last_position : Vector2
var momentum : Vector2

func set_position(new_position):
	var movement = get_parent().to_global(new_position) - global_position
	
	#first move the bodies
	for body in floor_touch_area.get_overlapping_bodies():
		body.global_position += movement
	
	#then move self
	position = new_position

func set_parts(parts: int):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts
	
	recolor_sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	recolor_sprite.rect_size.x = left_width + right_width + part_width * parts
	
	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	
func _ready():
	last_position = global_position
	area_collision_shape.shape = area_collision_shape.shape.duplicate()
	collision_shape.shape = collision_shape.shape.duplicate()
	
func _physics_process(delta):
	momentum = (global_position - last_position) / delta
		
	last_position = global_position



func _on_FloorTouchArea_body_exited(body):
	if body.get("velocity") != null:
		body.velocity += Vector2(momentum.x, min(0,momentum.y) )
