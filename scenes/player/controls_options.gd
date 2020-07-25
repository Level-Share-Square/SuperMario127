extends Node

export (Array, NodePath) var ignore_children

var currentButton : Button
var oldText : String

func _ready():
	# Prepare Presets
	var presetSelector = $"Preset Selection/Selector"
	for preset in ControlPresets.presets:
		presetSelector.add_item(preset)
		
func _input(event):
	if event is InputEventKey && event.pressed && currentButton != null:
		currentButton.text = OS.get_scancode_string(event.scancode)
		PlayerSettings.keybindings[currentButton.id] = event.scancode
		currentButton = null
	
func reset():
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null
