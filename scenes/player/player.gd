extends LevelDataLoader

export var character : NodePath
export var character2 : NodePath

var mode = 0
export var number_of_players = 2

func _ready():
	var data = CurrentLevelData.level_data
	load_in(data, data.areas[0])
	
func _process(delta):
	if Input.is_action_just_pressed("reload"):
		if !get_node(character).dead:
			get_node(character).kill("reload")
		elif number_of_players == 2:
			get_node(character2).kill("reload")

func switch_scenes():
	get_tree().change_scene("res://scenes/editor/editor.tscn")

func reload_scene():
	get_tree().reload_current_scene()
