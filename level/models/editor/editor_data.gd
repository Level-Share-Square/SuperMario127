class_name EditorData
extends LevelDataResource


const MAX_LOADOUTS: int = 4
const DEFAULT_ITEMS: Array = [
	Array(["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin", "obj_blue_coin", "obj_barrel_cactus", "til_cabin_window",]),
	Array(["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin", "obj_blue_coin", "obj_barrel_cactus", "til_cabin_window",]),
	Array(["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin", "obj_blue_coin", "obj_barrel_cactus", "til_cabin_window",]),
	Array(["obj_coin", "obj_mario", "til_grass", "til_brick", "obj_shine", "obj_star_coin", "obj_red_coin", "obj_blue_coin", "obj_barrel_cactus", "til_cabin_window",]),
]


var loadouts: Array = []
var palettes: Array = []
var fav_items: Array = []
var fav_counts: Array = []
var selected_loadout: int = 0


func _init(
		s_loadouts: Array = [], 
		s_palettes: Array = [], 
		s_fav_items: Array = [], 
		s_fav_counts: Array = [], 
		s_selected_loadout: int = 0
	) -> void:
	loadouts = s_loadouts
	palettes = s_palettes
	fav_items = s_fav_items
	fav_counts = s_fav_counts
	selected_loadout = s_selected_loadout
	
	var i = loadouts.size() - 1
	while i < MAX_LOADOUTS - 1:
		loadouts.append(DEFAULT_ITEMS[i])
		i += 1
	i = palettes.size() - 1
	while i < MAX_LOADOUTS - 1:
		palettes.append([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
		i += 1
	i = fav_items.size() - 1
	while i < MAX_LOADOUTS - 1:
		fav_items.append([])
		i += 1
	i = fav_counts.size() - 1
	while i < MAX_LOADOUTS - 1:
		fav_counts.append(0)
		i += 1
