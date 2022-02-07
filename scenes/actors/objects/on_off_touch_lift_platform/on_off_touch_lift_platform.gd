extends Node2D

export (Array, Texture) var palette_texture = []

onready var sprite = $Sprite
onready var recolor_sprite = $SpriteRecolor

onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

onready var parent = get_parent()

var last_position : Vector2
var momentum : Vector2

func set_position(new_position):
	if(parent.frozen == true):
		momentum = Vector2(0,0)
		last_position = momentum
		$StaticBody2D.constant_linear_velocity = momentum
		return
	var movement = get_parent().to_global(new_position) - global_position
	
	#first move the bodies
	$StaticBody2D.constant_linear_velocity = movement * 60
	
	#then move self
	position = new_position

func set_parts(parts: int):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts
	
	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2

func _ready():
	parent = get_parent()
	last_position = global_position
	collision_shape.shape = collision_shape.shape.duplicate()
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate()

func _physics_process(delta):
	if(parent.frozen == true):
		momentum = Vector2(0,0)
		last_position - momentum
		return
	momentum = (global_position - last_position) / fps_util.PHYSICS_DELTA
	
	last_position = global_position



func _on_PlatformArea_body_exited(body):
	if(parent.frozen == true):
		momentum = Vector2(0,0)
		last_position = momentum
		return
	if body.get("velocity") != null:
		body.velocity += Vector2(momentum.x, min(0, momentum.y))
