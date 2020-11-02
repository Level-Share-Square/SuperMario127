extends AudioStreamPlayer

onready var current_scene : Node = get_tree().current_scene
onready var cannon_position : Vector2 = get_parent().global_position

var character : PhysicsBody2D = null
var character2 : PhysicsBody2D = null

var current_volume := 0.0

func _ready() -> void:
	if "mode" in current_scene:
		if current_scene.mode == 0: # player
			character = current_scene.get_node(current_scene.character)
			character2 = current_scene.get_node(current_scene.character2)
		set_process(false)

func _process(_delta : float) -> void:
	var closest_character_position : Vector2 = character.global_position
	if is_instance_valid(character2) and cannon_position.distance_squared_to(character.global_position) \
			> cannon_position.distance_squared_to(character2.global_position):
		closest_character_position = character2.global_position
	
	volume_db = current_volume + -abs(closest_character_position.distance_to(get_parent().global_position) / 25)

func set_current_volume(new_value : float) -> void:
	current_volume = new_value
