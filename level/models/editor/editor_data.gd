class_name EditorData
extends LevelDataResource


const MAX_LOADOUTS: int = 4
const DEFAULT_ITEMS: Array = [
	Array(["til_grass", "til_snow", "til_sand", "til_crystal", "til_lava_rock", "til_brick", "obj_shine", "obj_coin", "obj_wood_platform", "obj_touch_lift",]),
	Array(["obj_pine_tree", "obj_big_tree", "obj_flower_bush", "obj_twisted_tree_top", "obj_mushroom_top", "obj_rock", "obj_arrow", "obj_goomba", "obj_koopa_troopa", "obj_bob_omb",]),
	Array(["obj_cannon", "obj_launch_star", "obj_sling_star", "obj_propeller", "obj_water", "obj_lava", "obj_note_block", "obj_spike_trap", "obj_sawblade", "obj_fire",]),
	Array(["obj_sign", "obj_toad", "obj_red_bob_omb", "obj_yoshi", "obj_dialogue_trigger", "obj_layer_changer", "obj_shine_activator", "obj_zoom_trigger", "obj_area_transition", "obj_death_plane",]),
]


var loadouts: Array = []
var palettes: Array = []
var fav_items: Array = []
var fav_counts: Array = []
var selected_loadout: int = 0

var selected_layer: String = ""
var show_palettes: bool = true
var area_bounds_increment: float = 10
var camera_positions: Array = [Vector2(288, 840)]
var last_area: int = 0
var pixel_snap := Vector2(8, 8)

func _init(
		s_loadouts: Array = [], 
		s_palettes: Array = [], 
		s_fav_items: Array = [], 
		s_fav_counts: Array = [], 
		s_selected_loadout: int = 0,
		s_selected_layer: String = "",
		s_show_palettes: bool = true,
		s_area_bounds_increment: float = 10,
		s_camera_positions: Array = [Vector2(288, 840)],
		s_last_area: int = 0,
		s_pixel_snap := Vector2(8, 8)
	) -> void:
	loadouts = s_loadouts
	palettes = s_palettes
	fav_items = s_fav_items
	fav_counts = s_fav_counts
	selected_loadout = s_selected_loadout
	
	var i = loadouts.size() - 1
	var default_index = 0
	while i < MAX_LOADOUTS - 1:
		loadouts.append(DEFAULT_ITEMS[default_index])
		i += 1
		default_index += 1
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
	
	selected_layer = s_selected_layer
	show_palettes = s_show_palettes
	area_bounds_increment = s_area_bounds_increment
	camera_positions = s_camera_positions
	last_area = s_last_area
	pixel_snap = s_pixel_snap
