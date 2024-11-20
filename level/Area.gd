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
	settings = duplicate_settings(base_area.settings)
	objects = base_area.duplicate_objects(base_area.objects)
	tile_chunks = base_area.tile_chunks.duplicate(true)

func duplicate_objects(base_objects: Array):
	var new_objects: Array
	for object in base_objects:
		var new_object = LevelObject.new()
		new_object.type_id = object.type_id
		new_object.palette = object.palette
		for prop in object.properties:
			#Prevents a bug that causes certain properties to become
			#Linked between two objects
			if typeof(prop) == TYPE_OBJECT:
				new_object.properties.append(prop.duplicate(true))
			else:
				new_object.properties.append(prop)
		
		new_objects.append(new_object)
	
	return new_objects

func duplicate_settings(base_settings):
	var new_settings = LevelAreaSettings.new()
	new_settings.sky = base_settings.sky
	new_settings.background = base_settings.background
	new_settings.background_palette = base_settings.background_palette
	new_settings.music = base_settings.music
	new_settings.bounds = base_settings.bounds
	new_settings.gravity = base_settings.gravity
	new_settings.timer = base_settings.timer
	
	return new_settings
