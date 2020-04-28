class_name LevelArea

var objects = []
var background_tiles := []
var foreground_tiles := []
var very_foreground_tiles := []
var settings := LevelAreaSettings.new()

func _init():
	if foreground_tiles.size() <= 0:
		for index in settings.size.x * settings.size.y:
			background_tiles.append([0, 0])
			foreground_tiles.append([0, 0])
			very_foreground_tiles.append([0, 0])
