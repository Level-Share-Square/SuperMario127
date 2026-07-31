extends GameObject

onready var sprite = $Top
onready var color_sprite = $Top/Color
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var visibility_notifier = $VisibilityNotifier2D

var wait_time = 3.0

var spawn_timer = 3.0
var chase := false
var speed := 0.75
var offset := 0.0
var color := Color(0, 1, 0)
var invincible := false
var force_direction := 0


func _register_properties():
	register_property(0, "chase", chase)
	register_property(1, "speed", speed)
	register_property(6, "offset", offset)
	register_property(2, "color", color)
	register_property(3, "wait_time", wait_time)
	register_property(4, "invincible", invincible)
	register_property(5, "force_direction", force_direction)
#	set_property_menu("force_direction", ["option", 3, -1, ['Face Player', 'Right', 'Left']])


func _ready():
	add_to_group("blasters")
	spawn_timer = wait_time + offset
	sprite.frame = 3


func _object_ready():
	collision_shape.disabled = !enabled


func _object_process(delta):
	if sprite.frame == 1 or sprite.frame == 2:
		sprite.scale = sprite.scale.linear_interpolate(Vector2(1.75, 1.75), delta * 12)
	else:
		sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 7)


func _object_physics_process(delta):
	if invincible:
		color.h = float(wrapi(OS.get_ticks_msec(), 0, 500)) / 500
	#rotation_degrees = 0
	color_sprite.modulate = color
		
	if mode != 1:
		spawn_timer -= delta
		if spawn_timer <= 0.35 and sprite.frame == 3:
			sprite.frame = 0

		if spawn_timer <= 0:
			spawn_timer = wait_time

			var facing_direction = 1
			
			var current_scene = get_tree().get_current_scene()
			var character
			var character_1 = current_scene.get_node(current_scene.character)
			
			if Singleton.PlayerSettings.number_of_players == 1:
				character = character_1
			else:
				var character_2 = current_scene.get_node(current_scene.character2)
				var char1_distance = global_position.distance_to(character_1.global_position)
				var char2_distance = global_position.distance_to(character_2.global_position)
	
				if (char1_distance < char2_distance or character_2.dead) and !character_1.dead:
					character = character_1
				else:
					character = character_2
			
			if character.position.x < position.x:
				facing_direction = -1
				
			if force_direction != 0:
				facing_direction = force_direction
			
			var prev_scale_x = scale.x
			scale.x = scale.y
			create_new_bill(chase, speed, color, facing_direction, invincible)
			
			scale.x = prev_scale_x
			
			if visibility_notifier.is_on_screen():
				get_tree().current_scene.get_node("SharedSounds").PlaySound("BlastLaunchSound")
				if chase:
					get_tree().current_scene.get_node("SharedSounds").PlaySound("BlastSeekSound")
			
		elif spawn_timer <= 0:
			spawn_timer = wait_time


func create_new_bill(chase, speed, color, facing_direction, invincible) -> Node:
	var object: GameObject = create_object(transform.xform(Vector2(16 * facing_direction, 0)), 25, 0)
	
	object.set_property("scale", scale)
	object.set_property("rotation_degrees", rotation_degrees)
	object.set_property("enabled", enabled)
	object.set_property("chase", chase)
	object.set_property("speed", speed)
	object.set_property("color", color)
	object.set_property("facing_direction", facing_direction)
	object.set_property("invincible", invincible)
	
	return object
