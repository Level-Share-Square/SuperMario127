extends Node

onready var shell_scene = load("res://scenes/actors/objects/koopa_troopa/shell.tscn")

onready var mario_sounds = load("res://scenes/actors/mario/mario_sounds.tscn")
onready var luigi_sounds = load("res://scenes/actors/mario/luigi_sounds.tscn")

var property_scenes = {
	
}

var music_nodes = [
	
]

func _ready():
	for property in load("res://scenes/editor/property_type_scenes/property_types.tres").ids:
		property_scenes[property] = load("res://scenes/editor/property_type_scenes/" + property + "/" + property + ".tscn")

	for song in load("res://assets/music/ids.tres").ids:
		music_nodes.append(load("res://assets/music/resources/" + song + ".tres"))
