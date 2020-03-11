extends LevelDataLoader

func _ready():
	var data = LevelData.new()
	data.load_in(load("res://assets/level_data/test_level.tres").contents)
	load_in(data, data.areas[0])
