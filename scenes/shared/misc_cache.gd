extends Node

## this script has a bunch of the same lazy loading stuff as the currentleveldata script does

var thread

var shell_scene setget ,get_shell_scene
func get_shell_scene():
	if !is_instance_valid(shell_scene):
		shell_scene = preload("res://scenes/actors/objects/koopa_troopa/shell.tscn")
	return shell_scene

var property_scenes = {
	
}

var music_nodes = [
	
]

var music_ids
var property_type_ids

func _init():
	music_ids = preload("res://assets/music/ids.tres").ids
	property_type_ids = preload("res://scenes/editor/property_type_scenes/property_types.tres").ids
	
	music_nodes.resize(music_ids.size())


func get_property_scene(property: String):
	if not property_scenes.has(property):
		var path: String = "res://scenes/editor/property_type_scenes/" + property + "/" + property + ".tscn"
		property_scenes[property] = load(path)
	
	return property_scenes[property]


func get_music_node(index: int):
	if music_nodes[index] != null:
		return music_nodes[index]
	
	var key: String = music_ids[index]
	var path: String = "res://assets/music/resources/" + key + ".tres"
	
	music_nodes[index] = load(path)
	return music_nodes[index]
