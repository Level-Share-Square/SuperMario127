extends Node

class_name PlaceableItem

export var tileset_id := 0
export var tile_id := 0
export var object_id := 0
export var is_object := false
export var object_center := Vector2(0, 0)
export var tile_mode_offset := Vector2(0, 0)
export var tile_mode_step := 32
export var palette_index := 0

export var item_name : String

export(Array, Texture) var palette_icons
export(Array, Texture) var palette_previews
export var object_size := Vector2(0, 0)
export var change_to : String = self.name

export var items_in_sequence := 0
export var index_in_sequence := 0

export var icon : Texture = null
export var preview : Texture = null

export var placement_action : Script
export var removal_action : Script

var backup_palette_index : int

func update_palette(new_index : int):
	if palette_icons.size() == 0: return
	palette_index = wrapi(new_index, 0, palette_icons.size())
	icon = palette_icons[palette_index]
	preview = palette_previews[palette_index]

func on_place(position: Vector2, level_data: LevelData, level_area: LevelArea):
	if is_instance_valid(placement_action):
		return placement_action.new().act(get_tree().current_scene, position, level_data, level_area)
	return true

func on_erase(position: Vector2, level_data: LevelData, level_area: LevelArea):
	if is_instance_valid(removal_action):
		return removal_action.new().act(get_tree().current_scene, position, level_data, level_area)
	return true
