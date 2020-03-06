extends TextureButton

class_name TileButton

export var is_tile = true
export var tileset_id := 1
export var tile_id := 0
export var object_type : String
export var tile_rect:Rect2 = Rect2(96, 0, 32, 32)
export var hotkey : int
onready var global_vars = get_node("../../../GlobalVars")
onready var tile_map = get_node("../../../TileMap")
onready var ghost_tile_container = get_node("../../../GhostTileContainer")

func _pressed():
	if !global_vars.is_tile && tile_map.ghost_object:
		tile_map.ghost_object.queue_free()
	if !is_tile:
		var ghost_object = load("res://src/editor_objects/" + object_type + ".gd").new()
		tile_map.ghost_object = ghost_object
		global_vars.currently_centered = ghost_object.placing_centered
		ghost_tile_container.add_child(ghost_object)
	global_vars.is_tile = is_tile
	global_vars.selected_tileset_id = tileset_id
	global_vars.selected_tile_id = tile_id
	global_vars.selected_object_type = object_type
	global_vars.placing_rect = tile_rect

func _input(event):
	if event is InputEventKey and event.scancode == hotkey and event.is_pressed() and !event.is_echo():		
		_pressed()
