extends Node

var thread
var thread2
var resource_loader
var resource_loader2

var shell_scene

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
	var loaded = false
	resource_loader = ResourceLoader.load_interactive("res://scenes/actors/objects/koopa_troopa/shell.tscn")
	while shell_scene == null:
		if resource_loader.poll() == ERR_FILE_EOF:
			shell_scene = resource_loader.get_resource()
		yield(get_tree().create_timer(0.5), "timeout")
		
	for music_name in music_ids:
		music_nodes.append(load("res://assets/music/resources/" + music_name + ".tres"))
		yield(get_tree().create_timer(0.15), "timeout")
	
	for property in property_type_ids:
		property_scenes[property] = load("res://scenes/editor/property_type_scenes/" + property + "/" + property + ".tscn")
		yield(get_tree().create_timer(0.15), "timeout")
