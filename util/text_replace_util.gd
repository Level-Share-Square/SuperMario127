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


static func input_to_text(input_key: String, player_id: int) -> String:
	var input_group: String = "Controls (Player " + str(player_id + 1) + ")"
	var is_controller: bool = (LastInputDevice.last_input_type == LastInputDevice.InputType.Controller)
	
	var action = input_settings_util.get_setting_partial(input_group, input_key, is_controller)
	if action.size() > 0:
		return COLOR_OPENING + input_event_util.get_singular_human_name(action[0]) + COLOR_CLOSING
	
	return COLOR_OPENING + "Unbound" + COLOR_CLOSING


static func parse_text(text : String, character : Character) -> String:
	text = text.replace(":char:", CHARACTER_NAMES[character.character].to_lower())
	text = text.replace(":Char:", CHARACTER_NAMES[character.character])
	text = text.replace(":CHAR:", CHARACTER_NAMES[character.character].to_upper())
	
	text = text.replace(":winginputs:", ":leftinput: and :rightinput:" if !Singleton.PlayerSettings.legacy_wing_cap else ":upinput: and :downinput:")
	
	var player = character.player_id
	for action in KEYBINDS:
		text = text.replace(":" + action + "input:", input_to_text(action, player))
	
	return text
