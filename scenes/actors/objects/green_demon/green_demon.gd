extends GameObject

onready var area = $Area2D
var collected = false
var character

var chase := false
var chase_speed := 1.0

var update_timer = 0.0

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
	if character != null and chase:
		if !character.dead:
			var move_to = (character.position - position).normalized()
			position += move_to * chase_speed
		
	if mode != 1 and chase:
		if update_timer <= 0:
			var current_scene = get_tree().get_current_scene()
			var character_1 = current_scene.get_node(current_scene.character)
			var character_2 = current_scene.get_node(current_scene.character2)
			
			if PlayerSettings.number_of_players == 1:
				character = character_1
			else:
				var char1_distance = position.distance_to(character_1.position)
				var char2_distance = position.distance_to(character_2.position)
	
				if (char1_distance < char2_distance or character_2.dead) and !character_1.dead:
					character = character_1
				else:
					character = character_2
			update_timer = 2.5
			
	if update_timer > 0:
		update_timer -= delta
		if update_timer <= 0:
			update_timer = 0
