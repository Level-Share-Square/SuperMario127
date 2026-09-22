extends GameObject


enum DisplayMode {Menu, Bubble, Both}

onready var dialogue_prefab = $Dialogue
onready var bubble_prefab = $SpeechBubble

var dialogue := PoolStringArray(["0100;This is a dialogue trigger.", "0100;Try putting this on top of an NPC and see what happens!"])
var character_name: String
var speaking_radius: float = 90
var autostart: int = 0
var interactable: bool = true
var zoom_size: float = 0.65

var bubble_text: String = "This text appears as a speech bubble above your NPC!"
var display_mode: int = 0

var tag: String
var delegate_tag: String

signal start_talking
signal stop_talking
signal change_emote(expression, action)


#func _set_properties():
#	savable_properties = ["dialogue", "character_name", "autostart", "interactable", "bubble_text", "display_mode", "tag", "delegate_tag", "zoom_size"]
#	editable_properties = ["dialogue", "bubble_text", "character_name", "display_mode", "zoom_size", "tag", "delegate_tag", "autostart", "interactable"]

func _register_properties():
	register_property(4, "dialogue", dialogue, false)
	register_property(5, "character_name", character_name, true)
	register_property(6, "autostart", autostart, true)
	set_property_override("autostart", PropertyTab.OverrideTypes.ENUM, ["Don't Autostart", "Autostart", "Autostart (Oneshot)"])
	register_property(7, "interactable", interactable, true)
	
	register_property(8, "bubble_text", bubble_text, false)
	register_property(9, "display_mode", display_mode, true)
	set_property_override("display_mode", PropertyTab.OverrideTypes.ENUM, ["Menu", "Speech Bubble", "Both"])
	
	register_property(10, "tag", tag, true)
	set_property_override("tag", PropertyTab.OverrideTypes.DROPDOWN, [CurrentLevelData.level_tags, "get_dialogue_args", [CurrentLevelData.level_tags, "dialogue_tags"]])
	register_property(11, "delegate_tag", delegate_tag, true)
	set_property_override("delegate_tag", PropertyTab.OverrideTypes.DROPDOWN, [CurrentLevelData.level_tags, "get_dialogue_args", [CurrentLevelData.level_tags, "dialogue_tags"]])
	register_property(12, "zoom_size", zoom_size, true)
	
	property_tabs.append("dialogue")


func _register_property_info():
	set_property_info("dialogue", PropertyInfo.new("The text this object will use when actively talking to it.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("character_name", PropertyInfo.new("The name this object will display when interacted with.\nCan be left empty.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("autostart", PropertyInfo.new("Automatically triggers dialogue when the player enters its area.\nIf set to (Oneshot), will only trigger once per area load.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("interactable", PropertyInfo.new("Whether the player can initiate the conversation themselves.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("bubble_text", PropertyInfo.new("Text that appears overhead when the player is nearby.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("display_mode", PropertyInfo.new("Menu: Will display text when interacted with.\nSpeech Bubble: Will display text when in close proximity.\nBoth: Will use Menu, then switch to Speech Bubble.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("tag", PropertyInfo.new("ID of this object, used for connecting triggers.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("delegate_tag", PropertyInfo.new("Will start dialogue from the specified object ID instead.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("zoom_size", PropertyInfo.new("Will specify the zoom amount when focused on the object.", 1, -INF, INF, ["", ""], ["", ""], false, "Zoom"))


func _ready():
	if mode == 1: return
	
	dialogue_prefab.connect("message_changed", self, "change_emote")
	dialogue_prefab.connect("message_disappear", self, "emit_signal", ["stop_talking"])
	dialogue_prefab.initialize()
	
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
		
