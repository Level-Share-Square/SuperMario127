extends LevelDataLoader

export var character : NodePath

var mode = 0

func _ready():
	var data = LevelData.new()
	data.load_in(load("res://assets/level_data/test_level.tres").contents)
	load_in(data, data.areas[0])
	
func _process(delta):
	if Input.is_action_just_pressed("reload"):
		reload_scene()

func switch_scenes():
	get_tree().change_scene("res://scenes/editor/editor.tscn")

func reload_scene():
	get_tree().reload_current_scene()
