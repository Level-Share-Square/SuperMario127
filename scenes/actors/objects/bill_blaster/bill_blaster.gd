extends GameObject

onready var sprite = $Top
onready var color_sprite = $Top/Color
onready var sound = $AudioStreamPlayer

var wait_time = 3.0

var spawn_timer = 3.0
var chase := false
var speed := 0.75
var color := Color(0, 1, 0)

func _set_properties():
	savable_properties = ["chase", "speed", "color", "wait_time"]
	editable_properties = ["chase", "speed", "color", "wait_time"]
	
func _set_property_values():
	set_property("chase", chase, true)
	set_property("speed", speed, true)
	set_property("color", color, true)
	set_property("wait_time", wait_time, true)
	spawn_timer = wait_time

func _physics_process(delta):
	color_sprite.modulate = color
	if mode != 1:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = wait_time
			sprite.frame = 0
			color_sprite.frame = 0
			
			var facing_direction = 1
			
			var current_scene = get_tree().get_current_scene()
			var character
			var character_1 = current_scene.get_node(current_scene.character)
			
			if PlayerSettings.number_of_players == 1:
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
			
			var object = LevelObject.new()
			object.type_id = 25
			object.properties = []
			object.properties.append(position + Vector2(4, 0))
			object.properties.append(Vector2(1, 1))
			object.properties.append(0)
			object.properties.append(true)
			object.properties.append(true)
			object.properties.append(chase)
			object.properties.append(speed)
			object.properties.append(color)
			object.properties.append(facing_direction)
			get_parent().create_object(object, false)
