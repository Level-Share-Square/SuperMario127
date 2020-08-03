extends Node2D

onready var area = $Area2D
onready var area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var body = $StaticBody2D

onready var sprite = $Sprite

export var middle_texture : StreamTexture

export var parts := 1
var buffer := -5
onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

func _ready():
	#make shapes unique so we don't accidently modify them for all platforms
	area_collision_shape.shape = area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	
	if !get_parent().enabled:
		collision_shape.disabled = true
	
	collision_shape.one_way_collision = false
	
func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
