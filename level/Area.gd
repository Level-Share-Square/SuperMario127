class_name LevelArea

var objects = []
var tile_chunks : = {}

#for loading only
var background_tiles := []
var very_background_tiles := []
var foreground_tiles := []
var very_foreground_tiles := []

var settings := LevelAreaSettings.new()

func _init():
	pass

func duplicate(base_area):
	objects = base_area.objects.duplicate(true)
	tile_chunks = base_area.tile_chunks.duplicate(true)
