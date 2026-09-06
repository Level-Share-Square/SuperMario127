class_name BigText
extends PropertyEditor

const MIN_SIZE: int = 17
const MIN_SIZE_SMALL: int = 12
const FONT: DynamicFont = preload("res://assets/fonts/delfino_small.tres")
const FONT_SMALL: DynamicFont = preload("res://assets/fonts/delfino_tiny.tres")

export var show_name: bool = false setget set_show_name
export var show_char: bool = true setget set_show_char
export var is_small: bool = false setget set_is_small
export var holds_property: bool = true
var text setget set_text, get_text

signal text_changed

var text_shortcut_map: Dictionary = {
	"character": ":char:",
	"Character": ":Shortcut:",
	"CHARACTER": ":CHAR:",
	"Shine Count": ":shinecount:",
	"Star Coin Count": ":starcoincount:",
	"Coin Count": ":coincount:",
	"Red Coin Count": ":redcoincount:",
	"Shine Shard Count": ":shineshardcount:",
	"Purple Starbit Count": ":starbitcount:",
	"Wing Inputs": ":winginputs:",
	"Jump Input": ":jumpinput:"
}

var campaign_text_shortcut_map: Dictionary = {
	"Total Shine Count": ":tshinecount:",
	"Total Star Coin Count": ":tstarcoincount:"
}

func _ready():
	var working_map: Dictionary = text_shortcut_map.duplicate()
	if CurrentLevelData.is_campaign: working_map.merge(campaign_text_shortcut_map)
	
	for shortcut in working_map:
		$"%Shortcut".add_item(shortcut)

func set_text(new_value: String) -> void:
	$"%TextEditor".text = new_value

func get_text() -> String:
	return $"%TextEditor".text

func set_show_name(new_value: bool) -> void:
	show_name = new_value
	get_node("%PropertyName").visible = new_value

func set_show_char(new_value: bool) -> void:
	show_char = new_value
	get_node("%Shortcut").visible = new_value
	get_node("%ShortcutVSeparator").visible = new_value

func set_is_small(new_value: bool) -> void:
	is_small = new_value
	for button in $"%ModifierButtons".get_children():
		if button is Button:
			button.rect_min_size = Vector2(MIN_SIZE_SMALL, MIN_SIZE_SMALL) if new_value else Vector2(MIN_SIZE, MIN_SIZE)
	$"%TextEditor".add_font_override("font", FONT_SMALL if new_value else FONT)

func property_changed(key: String, new_value):
	if not holds_property: return
	if key != property[0]: return
	$"%TextEditor".text = str(new_value)

func change_property(new_value, save_to_data: bool = true):
	if not holds_property: return
	.change_property(str(new_value), save_to_data)

func done_editing():
	if holds_property:
		change_property($"%TextEditor".text)
	else:
		emit_signal("focus_exited")


func shortcut_selected(index):
	var working_map: Dictionary = text_shortcut_map.duplicate()
	if CurrentLevelData.is_campaign: working_map.merge(campaign_text_shortcut_map)
	
	$"%TextEditor".add_string(working_map.values()[index])
