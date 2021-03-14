extends GameObject

onready var sprite = $Top
onready var color_sprite = $Top/Color
onready var sound = $AudioStreamPlayer
onready var collision_shape = $StaticBody2D/CollisionShape2D

var wait_time = 3.0

var spawn_timer = 3.0
var chase := false
var speed := 0.75
var color := Color(0, 1, 0)
var invincible := false
var force_direction := 0

func _set_properties():
	savable_properties = ["chase", "speed", "color", "wait_time", "invincible", "force_direction"]
	editable_properties = ["chase", "speed", "color", "wait_time", "invincible", "force_direction"]
	
func _set_property_values():
	set_property("chase", chase, true)
	set_property("speed", speed, true)
	set_property("color", color, true)
	set_property("wait_time", wait_time, true)
	set_property("invincible", invincible, true)
	set_property("force_direction", force_direction, true)
	spawn_timer = wait_time

func _ready():
	collision_shape.disabled = !enabled

func _process(delta):
	if sprite.frame == 1 or sprite.frame == 2:
		sprite.scale = sprite.scale.linear_interpolate(Vector2(1.75, 1.75), delta * 12)
	else:
		sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 7)

func _physics_process(delta):
	if invincible:
		color.h = float(wrapi(OS.get_ticks_msec(), 0, 500)) / 500
	#rotation_degrees = 0
	color_sprite.modulate = color
		
	if mode != 1:
		spawn_timer -= delta
		if spawn_timer <= 0.35 and sprite.frame == 3 and Singleton.CurrentLevelData.enemies_instanced < 50:
			sprite.frame = 0
			color_sprite.frame = 0

		if spawn_timer <= 0 and Singleton.CurrentLevelData.enemies_instanced < 55:
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
			
			var object = LevelObject.new()
			object.type_id = 25
			object.properties = []
			object.properties.append(transform.xform(Vector2(16 * facing_direction, 0)))
			object.properties.append(scale)
			object.properties.append(rotation_degrees)
			object.properties.append(enabled)
			object.properties.append(true)
			object.properties.append(chase)
			object.properties.append(speed)
			object.properties.append(color)
			object.properties.append(facing_direction)
			object.properties.append(invincible)
			get_parent().create_object(object, false)
			
			scale.x = prev_scale_x
		elif spawn_timer <= 0:
			spawn_timer = wait_time
