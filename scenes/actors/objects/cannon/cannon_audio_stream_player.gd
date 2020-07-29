extends AudioStreamPlayer

onready var current_scene = get_tree().current_scene
onready var cannon_position = get_parent().global_position

var character 
var character2

var current_volume = 0

func _ready():
	if "mode" in current_scene:
		if current_scene.mode == 0: #player
			character = current_scene.get_node(current_scene.character)
			character2 = current_scene.get_node(current_scene.character2)
		elif current_scene.mode == 1: #editor
			set_process(false)

func _process(_delta):
	var closest_character_position = character.global_position
	if character2 != null and cannon_position.distance_squared_to(character.global_position) > cannon_position.distance_squared_to(character2.global_position):
		closest_character_position = character2.global_position
	
	volume_db = current_volume + -abs(closest_character_position.distance_to(get_parent().global_position) / 25)
