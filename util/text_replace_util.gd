class_name text_replace_util

static func parse_text(text : String, character : Character):
	var character_names = [
		"Mario",
		"Luigi"
	]

	text = text.replace(":char:", character_names[character.character].to_lower())
	text = text.replace(":Char:", character_names[character.character])
	text = text.replace(":CHAR:", character_names[character.character].to_upper())
	
	text = text.replace(":winginputs:", ":leftinput: and :rightinput:" if !PlayerSettings.legacy_wing_cap else ":upinput: and :downinput:")
	
	text = text.replace(":leftinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("left", character.player_id) + "[/color]"
	)
	text = text.replace(":rightinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("right", character.player_id) + "[/color]"
	)
	text = text.replace(":upinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("up", character.player_id) + "[/color]"
	)
	text = text.replace(":downinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("down", character.player_id) + "[/color]"
	)
	text = text.replace(":jumpinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("jump", character.player_id) + "[/color]"
	)
	text = text.replace(":spininput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("spin", character.player_id) + "[/color]"
	)
	text = text.replace(":diveinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("dive", character.player_id) + "[/color]"
	)
	text = text.replace(":gpinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("gp", character.player_id) + "[/color]"
	)
	text = text.replace(":gpcancelinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("gpcancel", character.player_id) + "[/color]"
	)
	text = text.replace(":fluddinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("fludd", character.player_id) + "[/color]"
	)
	text = text.replace(":nozzlesinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("nozzles", character.player_id) + "[/color]"
	)
	text = text.replace(":crouchinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("crouch", character.player_id) + "[/color]"
	)
	text = text.replace(":interactinput:", 
		"[color=#7dcbff]" + ControlUtil.get_formatted_string("interact", character.player_id) + "[/color]"
	)
	return text
