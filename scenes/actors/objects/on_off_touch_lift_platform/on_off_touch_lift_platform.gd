extends Node2D

export (Array, Texture) var palette_texture = []

onready var sprite = $Sprite
onready var sprite2 = $Sprite2

onready var platform_area_collision_shape = $StaticBody2D/Area2D/CollisionShape2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = 15

onready var parent = get_parent()

var last_position : Vector2
var momentum : Vector2

func set_position(new_position):
	if(parent.frozen == true):
		momentum = Vector2(0,0)
		last_position = momentum
		$StaticBody2D.constant_linear_velocity = momentum
		#set_position(Vector2(stepify(position.x, 1), stepify(position.y, 1)))
		return
	var movement = get_parent().to_global(new_position) - global_position
	
	#first move the bodies
	$StaticBody2D.constant_linear_velocity = movement * 60
	
	#then move self
	position = new_position

func set_parts(parts: int):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts
	
	sprite2.rect_position.x = sprite.rect_position.x

	sprite2.rect_size.x = sprite.rect_size.x

	
	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2

func _ready():
	parent = get_parent()
	
	sprite.region_rect.position.y = int(parent.palette) * 13
	
	sprite.region_rect.position.x = int(!parent.disappears) * 46
	

	sprite2.region_rect.position.y = sprite.region_rect.position.y
	sprite2.region_rect.position.x = 23 + int(!parent.disappears) * 46
	
	last_position = global_position
	collision_shape.shape = collision_shape.shape.duplicate()
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate()
	
	Singleton.CurrentLevelData.level_data.vars.connect("switch_state_changed", self, "_on_switch_state_changed")
	
	_on_switch_state_changed(true, parent.palette)
	
	#parent._ready()
	#parent._set_platform_pos()
		


func _physics_process(delta):


	
	if(parent.frozen == true):
		momentum = Vector2(0,0)
		$StaticBody2D.constant_linear_velocity = momentum
		return
	momentum = (global_position - last_position) / fps_util.PHYSICS_DELTA
	
	last_position = global_position
	sprite.region_rect.position.x = int(!parent.disappears) * 46

	sprite2.region_rect.position.x = 23 + int(!parent.disappears) * 46


func _on_PlatformArea_body_exited(body):
	if(parent.frozen == true):
		momentum = Vector2(0,0)
		last_position = momentum
		return
	if body.get("velocity") != null:
		body.velocity += Vector2(momentum.x, min(0, momentum.y))

func _on_switch_state_changed(new_state, channel):
	if parent.palette == channel:
		if(parent.inverted):
			new_state = !new_state
		if(parent.disappears):
			$StaticBody2D.set_collision_layer_bit(4, new_state)
			sprite.visible = new_state
			sprite2.visible = !new_state
		else:
			sprite.visible = true
			parent.frozen = !new_state
			sprite2.region_rect.position.x = 69 + int(!new_state) * 23
			
			
			

	
