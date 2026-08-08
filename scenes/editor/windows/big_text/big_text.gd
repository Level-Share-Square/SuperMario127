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


func set_text(new_value: String) -> void:
	$"%TextEditor".text = new_value

func get_text() -> String:
	return $"%TextEditor".text

func set_show_name(new_value: bool) -> void:
	show_name = new_value
	get_node("%PropertyName").visible = new_value

func set_show_char(new_value: bool) -> void:
	show_char = new_value
	get_node("%Char").visible = new_value
	get_node("%CharVSeparator").visible = new_value

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

func change_property(new_value):
	if not holds_property: return
	.change_property(str(new_value))

func done_editing():
	if holds_property:
		change_property($"%TextEditor".text)
	else:
		emit_signal("focus_exited")
