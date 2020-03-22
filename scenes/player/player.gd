extends LevelDataLoader

export var character : NodePath

var mode = 0

func _ready():
	var data = CurrentLevelData.level_data
	load_in(data, data.areas[0])
	
func _process(delta):
	if Input.is_action_just_pressed("reload"):
		get_node(character).kill("reload")

func switch_scenes():
	get_tree().change_scene("res://scenes/editor/editor.tscn")

func reload_scene():
	get_tree().reload_current_scene()
