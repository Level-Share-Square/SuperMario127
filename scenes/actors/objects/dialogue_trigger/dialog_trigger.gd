extends GameObject


var dialogue := PoolStringArray(["0100This is a dialogue object.", "0100Try putting this on top of an object and see what happens!"])
var character_name: String = "NPC"
var speaking_radius: float = 90
var autostart: int = 0
var interactable: bool = true

func _set_properties():
	savable_properties = ["dialogue", "character_name", "autostart", "interactable"]
	editable_properties = ["dialogue", "character_name", "autostart", "interactable"]
	
func _set_property_values():		
	set_property("dialogue", dialogue, true)
	set_property("character_name", character_name, true)
	set_property("autostart", autostart, true)
	set_property_menu("autostart", ["option", 3, 0, ["Don't Autostart", "Autostart", "Autostart (Oneshot)"]])
	set_property("interactable", interactable, true)
	
