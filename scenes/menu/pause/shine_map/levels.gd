extends VBoxContainer

const LEVEL_INFO_SCENE: PackedScene = preload("res://scenes/menu/pause/shine_map/level.tscn")


func screen_opened():
	for child in get_children():
		child.queue_free()
		
	var meta_dict: Dictionary = Singleton.CurrentLevelData.get_meta_dict()
	for level_dict in meta_dict.get("levels", {}).values():
		if level_dict.get("total_shines", 0) > 0 or level_dict.get("total_star_coins", 0) > 0:
			var level_info: Control = LEVEL_INFO_SCENE.instance()
			level_info.level_dict = level_dict
			add_child(level_info)
