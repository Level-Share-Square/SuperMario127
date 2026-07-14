class_name AreaDataOld
extends Resource


export var bounds: Rect2 = Rect2(0, 0, 80, 30)

export var objects = []
export var tile_chunks : = {}

#for loading only
export var background_tiles := []
export var very_background_tiles := []
export var foreground_tiles := []
export var very_foreground_tiles := []

export var name: String = ""

export var sky: int = 1
export var background: int = 1
export var background_palette: int = 0
export var bg_autoscroll_speed: float = 0.0

export var gravity: float = 7.82
export var timer: float = 0.00

# can hold either the ID for music in the files or a link to custom music
export var music = 1
export var underwater_music: String = ""


func duplicate_objects(base_objects: Array):
	var new_objects: Array
	for object in base_objects:
		var new_object = ObjectDataOld.new()
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
