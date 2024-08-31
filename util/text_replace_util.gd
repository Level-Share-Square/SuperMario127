class_name text_replace_util

static func input_to_text(action_name: String, player_id: int) -> String:
	var action = LocalSettings.load_setting("Controls (Player " + str(player_id + 1) + ")", action_name, [])
	if action.size() > 0:
		return "[color=#7dcbff]" + bindings_util.get_singular_human_name(action[0]) + "[/color]"
	
	return "[color=#7dcbff]" + "Unbound" + "[/color]"


static func parse_text(text : String, character : Character) -> String:
	var character_names = [
		"Mario",
		"Luigi"
	]

	text = text.replace(":char:", character_names[character.character].to_lower())
	text = text.replace(":Char:", character_names[character.character])
	text = text.replace(":CHAR:", character_names[character.character].to_upper())
	
	text = text.replace(":winginputs:", ":leftinput: and :rightinput:" if !Singleton.PlayerSettings.legacy_wing_cap else ":upinput: and :downinput:")
	
	var player = character.player_id
	
	text = text.replace(":leftinput:", input_to_text("left", player))
	text = text.replace(":rightinput:", input_to_text("right", player))
	text = text.replace(":upinput:", input_to_text("up", player))
	text = text.replace(":downinput:", input_to_text("down", player))
	text = text.replace(":jumpinput:", input_to_text("jump", player))
	text = text.replace(":spininput:", input_to_text("spin", player))
	text = text.replace(":diveinput:", input_to_text("dive", player))
	text = text.replace(":gpinput:", input_to_text("gp", player))
	text = text.replace(":gpcancelinput:", input_to_text("gpcancel", player))
	text = text.replace(":fluddinput:", input_to_text("fludd", player))
	text = text.replace(":nozzlesinput:", input_to_text("nozzles", player))
	text = text.replace(":crouchinput:", input_to_text("crouch", player))
	text = text.replace(":interactinput:", input_to_text("interact", player))
	return text
