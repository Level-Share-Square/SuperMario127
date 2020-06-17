extends Node

class_name PlaceableItem

export var tileset_id := 0
export var tile_id := 0
export var object_id := 0
export var is_object := false
export var object_center := Vector2(0, 0)
export var tile_mode_offset := Vector2(0, 0)
export var tile_mode_step := 32
export var object_size := Vector2(0, 0)
export var z_index := 0
export var change_to : String = self.name

export var items_in_sequence := 0
export var index_in_sequence := 0

export var icon : Texture = null
export var preview : Texture = null

export var has_placement_action := false
export var placement_action : Script

export var has_removal_action := false
export var removal_action : Script

func on_place(position: Vector2, level_data: LevelData, level_area: LevelArea):
	if has_placement_action:
		return placement_action.new().act(get_tree().get_current_scene(), position, level_data, level_area)
	else:
		return true

func on_erase(position: Vector2, level_data: LevelData, level_area: LevelArea):
	if has_removal_action:
		return removal_action.new().act(get_tree().get_current_scene(), position, level_data, level_area)
	else:
		return true
