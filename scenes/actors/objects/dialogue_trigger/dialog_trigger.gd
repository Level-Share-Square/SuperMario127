extends GameObject


enum DisplayMode {Menu, Bubble, Both}

onready var dialogue_prefab = $Dialogue
onready var bubble_prefab = $SpeechBubble

var dialogue := PoolStringArray(["0100;This is a dialogue object.", "0100;Try putting this on top of an NPC and see what happens!"])
var character_name: String
var speaking_radius: float = 90
var autostart: int = 0
var interactable: bool = true

var bubble_text: String = "This text appears as a speech bubble above your NPC!"
var display_mode: int = 0

var tag: String
var remote_tag: String

signal start_talking
signal stop_talking
signal change_emote(expression, action)


func _set_properties():
	savable_properties = ["dialogue", "character_name", "autostart", "interactable", "bubble_text", "display_mode", "tag", "remote_tag"]
	editable_properties = ["dialogue", "bubble_text", "character_name", "display_mode", "tag", "remote_tag", "autostart", "interactable"]
	
func _set_property_values():		
	set_property("dialogue", dialogue, true)
	set_property("character_name", character_name, true)
	set_property("autostart", autostart, true)
	set_property_menu("autostart", ["option", 3, 0, ["Don't Autostart", "Autostart", "Autostart (Oneshot)"]])
	set_property("interactable", interactable, true)
	
	set_property("bubble_text", bubble_text, true)
	set_property("display_mode", display_mode, true)
	set_property_menu("display_mode", ["option", 3, 0, ["Menu", "Speech Bubble", "Both"]])
	
	set_property("tag", tag, true)
	set_property("remote_tag", remote_tag, true)


func _ready():
	if mode == 1: return
	
	dialogue_prefab.connect("message_changed", self, "change_emote")
	dialogue_prefab.connect("message_disappear", self, "emit_signal", ["stop_talking"])
	
	bubble_prefab.connect("message_appear", self, "emit_signal", ["start_talking"])
	bubble_prefab.connect("message_disappear", self, "emit_signal", ["stop_talking"])
	
	match display_mode:
		DisplayMode.Menu:
			bubble_prefab.hide()
		
		DisplayMode.Bubble:
			dialogue_prefab.interactable = false
			dialogue_prefab.hide()
		
		DisplayMode.Both:
			bubble_prefab.hide()


func menu_closed():
	if display_mode == DisplayMode.Both:
		dialogue_prefab.interactable = false
		dialogue_prefab.hide()
		bubble_prefab.show()


func change_emote(expression, action):
	emit_signal("change_emote", expression, action)
		
