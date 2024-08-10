extends GameObject


var dialogue := PoolStringArray(["0100This is a dialogue object.", "0100Try putting this on top of an object and see what happens!"])
var character_name: String = "NPC"
var speaking_radius: float = 90

func _set_properties():
	savable_properties = ["dialogue", "character_name"]
	editable_properties = ["dialogue", "character_name"]
	
func _set_property_values():		
	set_property("dialogue", dialogue, true)
	set_property("character_name", character_name, true)
	
