extends Node

signal photo_mode_changed

export var enabled := false setget set_enabled
func set_enabled(new_value: bool):
	enabled = new_value
	emit_signal("photo_mode_changed")
