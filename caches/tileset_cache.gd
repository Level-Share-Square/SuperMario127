extends Node

class_name TilesetCache

var cache := []

func _ready():
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	for tileset_id in level_tilesets.tilesets:
		var tileset : level_tileset = load("res://assets/tiles/" + tileset_id + "/resource.tres")
		cache.append(tileset)
