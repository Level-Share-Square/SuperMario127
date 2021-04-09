extends Node

var thread

var shell_scene
var loaded_ids := 0
var loaded_ids_max := 0

var property_scenes = {
	
}

var music_nodes = [
	
]

onready var music_ids = preload("res://assets/music/ids.tres").ids
onready var property_type_ids = preload("res://scenes/editor/property_type_scenes/property_types.tres").ids

func _ready():
	thread = Thread.new()
	thread.start(self, "load_resources")

func load_resources(userdata):
	loaded_ids_max = 1 + music_ids.size() + property_type_ids.size()
	loaded_ids = 0
	var resource_loader
	
	resource_loader = ResourceLoader.load_interactive("res://scenes/actors/objects/koopa_troopa/shell.tscn")
	while true:
		OS.delay_msec(1)
		
		if resource_loader.poll() == ERR_FILE_EOF:
			shell_scene = resource_loader.get_resource()
			loaded_ids += 1
			break
	
	for music_name in music_ids:
		resource_loader = ResourceLoader.load_interactive("res://assets/music/resources/" + music_name + ".tres")
		while true:
			OS.delay_msec(1)
			
			if resource_loader.poll() == ERR_FILE_EOF:
				music_nodes.append(resource_loader.get_resource())
				loaded_ids += 1
				break
	
	for property in property_type_ids:
		resource_loader = ResourceLoader.load_interactive("res://scenes/editor/property_type_scenes/" + property + "/" + property + ".tscn")
		while true:
			OS.delay_msec(1)
			
			if resource_loader.poll() == ERR_FILE_EOF:
				property_scenes[property] = resource_loader.get_resource()
				loaded_ids += 1
				break
