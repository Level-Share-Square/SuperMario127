class_name text_replace_util


const COLOR_OPENING: String = "[color=#7dcbff]"
const COLOR_CLOSING: String = "[/color]"

const KEYBINDS: Array = [
	"left",
	"right",
	"up",
	"down",
	"jump",
	"spin",
	"dive",
	"gp",
	"gpcancel",
	"fludd",
	"nozzles",
	"crouch",
	"interact"
]

const CHARACTER_NAMES: Array = [
	"Mario",
	"Luigi"
]

const SAVE_COLLECTIBLE_DICT: Dictionary = {
	":shinecount:": "get_completed_mission_count",
	":starcoincount:": "get_collected_star_coin_count",
}

const VARS_COLLECTIBLE_DICT: Dictionary = {
	":coincount:": "coins_collected",
	":redcoincount:": "red_coins_collected",
	":shineshardcount:": "shine_shards_collected",
	":starbitcount:": "purple_starbits_collected",
}

const META_COLLECTIBLE_DICT: Dictionary = {
	":tshinecount:": "",
	":tstarcoincount:": "",
}


static func input_to_text(input_key: String, player_id: int = 0, override_subgroup: String = "") -> String:
	var subgroup: String = "Player " + str(player_id + 1)
	if override_subgroup != "":
		subgroup = override_subgroup
	var input_group: String = "Controls (%s)" % subgroup
	var is_controller: bool = (LastInputDevice.last_input_type == LastInputDevice.InputType.Controller)
	
	if LastInputDevice.last_input_type != LastInputDevice.InputType.Touch:
		var action = input_settings_util.get_setting_partial(input_group, input_key, is_controller)
		if action.size() > 0:
			return COLOR_OPENING + input_event_util.get_singular_human_name(action[0]) + COLOR_CLOSING
	else:
		return COLOR_OPENING + input_event_util.get_touch_name(input_key) + COLOR_CLOSING
	
	return COLOR_OPENING + "Unbound" + COLOR_CLOSING


static func input_to_collectible_value(input_key: String, save: LevelSaveData = null, vars: LevelVars = null, current_area: int = 0) -> String:
	if input_key in SAVE_COLLECTIBLE_DICT.keys():
		if not is_instance_valid(save): return "0"
		return str(save.call(SAVE_COLLECTIBLE_DICT[input_key]))

	elif input_key in VARS_COLLECTIBLE_DICT.keys():
		
		if not is_instance_valid(vars): return "0"
		var variable = vars[VARS_COLLECTIBLE_DICT[input_key]]
		if variable is Array:
			var nested_variable = variable[0]
			if nested_variable is int: return str(nested_variable)
			
			nested_variable = variable[current_area]
			return str(nested_variable[0])
		return str(variable)
		
	elif input_key in META_COLLECTIBLE_DICT.keys():
		return ""
	else:
		return ""

static func parse_text(text: String, character: Character, save: LevelSaveData = null, vars: LevelVars = null, current_area: int = 0) -> String:
	text = text.replace(":char:", CHARACTER_NAMES[character.character].to_lower())
	text = text.replace(":Char:", CHARACTER_NAMES[character.character])
	text = text.replace(":CHAR:", CHARACTER_NAMES[character.character].to_upper())
	
	var is_controller: bool = LastInputDevice.last_input_type == LastInputDevice.InputType.Controller
	var legacy_wing_cap: bool = LocalSettings.load_setting(
		"Controls (Player 1)" + input_settings_util.get_group_suffix(is_controller), 
		"63_wing_cap",
		false
	)
	if LastInputDevice.last_input_type == LastInputDevice.InputType.Touch:
		legacy_wing_cap = true
	
	text = text.replace(":winginputs:", ":leftinput: and :rightinput:" if !legacy_wing_cap else ":upinput: and :downinput:")
	
	var player = character.player_id
	for action in KEYBINDS:
		text = text.replace(":" + action + "input:", input_to_text(action, player))
	
	var working_dict: Dictionary = SAVE_COLLECTIBLE_DICT.duplicate()
	working_dict.merge(META_COLLECTIBLE_DICT)
	working_dict.merge(VARS_COLLECTIBLE_DICT)
	
	for coll in working_dict:
		text = text.replace(coll, input_to_collectible_value(coll, save, vars)) 
	
	return text
