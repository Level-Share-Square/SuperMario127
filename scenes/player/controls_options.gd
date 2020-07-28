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
	if event is InputEventMouseMotion:
		return
		
	if (event is InputEventJoypadMotion || event.pressed) && currentButton != null:
		if event is InputEventKey:
			PlayerSettings.keybindings[currentButton.id] = {0: event.scancode}
		elif event is InputEventMouseButton:
			PlayerSettings.keybindings[currentButton.id] = {ControlUtil.MOUSE: event.button_index}
		elif event is InputEventJoypadButton:
			PlayerSettings.keybindings[currentButton.id] = {
				ControlUtil.JOYPAD_BUTTON:  [
					event.device,
					event.button_index
				]
			}
		elif event is InputEventJoypadMotion:
			if abs(event.axis_value) > 0.5:
				PlayerSettings.keybindings[currentButton.id] = {
					ControlUtil.JOYPAD_MOTION: [
						event.device,
						event.axis,
						1 if event.axis_value > 0 else -1
					]
				}
			else:
				return
		else:
			return
		
		setNewTextAndReset()
	
func reset():
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null

func setNewTextAndReset():
	currentButton.text = ControlUtil.get_formatted_string(currentButton.id)
	SettingsSaver.override_keybindings(currentButton.id)
	currentButton = null
