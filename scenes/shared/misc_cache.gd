extends Node

var thread
var thread2
var resource_loader
var resource_loader2

var shell_scene

var mario_sounds
var luigi_sounds

var property_scenes = {
	
}

var music_nodes = [
	
]

onready var music_ids = preload("res://assets/music/ids.tres").ids
onready var property_type_ids = preload("res://scenes/editor/property_type_scenes/property_types.tres").ids

func _ready():
	thread = Thread.new()
	thread.start(self, "load_resources")
	
	#thread2 = Thread.new()
	#thread2.start(self, "load_sounds", null, thread.PRIORITY_HIGH)

#func load_sounds(userdata):
#	resource_loader2 = ResourceLoader.load_interactive("res://scenes/actors/mario/mario_sounds.tscn")
#	while mario_sounds == null:
#		if resource_loader2.poll() == ERR_FILE_EOF:
#			mario_sounds = resource_loader2.get_resource()
#		yield(get_tree().create_timer(0.5), "timeout")
#
#	resource_loader2 = ResourceLoader.load_interactive("res://scenes/actors/mario/luigi_sounds.tscn")
#	while luigi_sounds == null:
#		if resource_loader2.poll() == ERR_FILE_EOF:
#			luigi_sounds = resource_loader2.get_resource()
#		yield(get_tree().create_timer(0.5), "timeout")

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
