extends Node2D

onready var area = $Area2D
onready var area_collision_shape = $Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var body = $StaticBody2D

onready var parts_holder = $Parts
onready var left = $LeftSprite
onready var right = $RightSprite

export var middle_texture : StreamTexture

export var parts := 1
var buffer := -5
export var left_width = 22
export var right_width = 24
export var base_collision_width = 13
export var part_width = 19

func _ready():
	if !get_parent().enabled:
		collision_shape.disabled = true
#	if get_parent().mode != 1:   this seems to be unused
#		var _connect = area.connect("body_entered", self, "enter_area")
#		var _connect2 = area.connect("body_exited", self, "exit_area")
		
func update_parts():
	for part_sprite in parts_holder.get_children():
		part_sprite.queue_free()
	
	for index in range(parts):
		var part = Sprite.new()
		part.centered = false
		part.texture = middle_texture
		part.position.x = left_width + (part_width * index)
		part.position.y = -8
		parts_holder.add_child(part)
	right.position.x = left_width + (part_width * parts)
	
	var area_shape = RectangleShape2D.new()
	area_shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	area_shape.extents.y = 32
	area_collision_shape.position.x = (left_width + (part_width * parts) + right_width) / 2
	area_collision_shape.shape = area_shape
	
	var rect_shape = RectangleShape2D.new()
	rect_shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	rect_shape.extents.y = 5
	collision_shape.position.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape = rect_shape
	
	position.x = -(left_width + (part_width * parts) + right_width) / 2
	
func can_collide_with(character):
	var direction = body.global_transform.y.normalized()
	
	var is_grounded = character.is_grounded() if character.has_method("is_grounded") else true
	var line_center = body.global_position + (direction * buffer)
	var line_direction = Vector2(-direction.y, direction.x)
	var p1 = line_center + line_direction
	var p2 = line_center - line_direction
	var p = character.bottom_pos.global_position if is_grounded else character.global_position
	var diff = p2 - p1
	var perp = Vector2(-diff.y, diff.x)
	# A threshold that should prevent clips
	if character.get("velocity") != null and !is_grounded:
		var d = character.velocity.dot(perp)
		if d < 0:
			return false
		
		p -= character.velocity.normalized()
	else:
		p -= perp
	
	var d = (p - p1).dot(perp)
	return sign(d) != 1
