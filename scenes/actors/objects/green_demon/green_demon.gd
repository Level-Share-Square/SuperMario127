extends GameObject

onready var area = $Area2D
var collected = false
var character

var chase := false
var chase_speed := 1.0

var update_timer = 0.0
var char_find_timer = 0.0

var cached_pos := Vector2()

func _set_properties():
	savable_properties = ["chase", "chase_speed"]
	editable_properties = ["chase", "chase_speed"]
	
func _set_property_values():
	set_property("chase", chase, true)
	set_property("chase_speed", chase_speed, true)

func kill(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable:
		body.kill("green_demon")
		queue_free()

func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "kill")

func _physics_process(delta):
	if cached_pos != Vector2() and chase and character != null:
		var move_to = (cached_pos - position).normalized()
		position += move_to * chase_speed
		
	if mode != 1 and chase:
		if update_timer <= 0:
			if character != null:
				if !character.dead:
					cached_pos = character.position
			update_timer = 0.15
			
		if char_find_timer <= 0:
			var current_scene = get_tree().get_current_scene()
			var character_1 = current_scene.get_node(current_scene.character)
			
			if PlayerSettings.number_of_players == 1:
				character = character_1
			else:
				var character_2 = current_scene.get_node(current_scene.character2)
				var char1_distance = position.distance_to(character_1.position)
				var char2_distance = position.distance_to(character_2.position)
	
				if (char1_distance < char2_distance or character_2.dead) and !character_1.dead:
					character = character_1
				else:
					character = character_2
			cached_pos = character.position
			char_find_timer = 3.5
			
	if char_find_timer > 0:
		char_find_timer -= delta
		if char_find_timer <= 0:
			char_find_timer = 0
			
	if update_timer > 0:
		update_timer -= delta
		if update_timer <= 0:
			update_timer = 0
