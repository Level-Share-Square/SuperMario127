extends Node

export (Array, NodePath) var ignore_children
export (Array, NodePath) var menu_buttons

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
		var result : Array
		if event is InputEventKey:
			result = [
				ControlUtil.KEYBOARD, event.scancode
			]
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT:
				for children in get_children():
					if !children.get_name() in ignore_children:
						var button : Button = children.get_node("KeyButton")
						if button.is_hovered():
							return
				
			if event.button_index == BUTTON_LEFT:
				for button in menu_buttons:
					if get_node(button).is_hovered():
						return

			result = [
				ControlUtil.MOUSE, event.button_index
			]
		elif event is InputEventJoypadButton:
			result = [
				ControlUtil.JOYPAD_BUTTON,
				event.device,
				event.button_index
			]
		elif event is InputEventJoypadMotion:
			if abs(event.axis_value) > 0.5:
				result = [
					ControlUtil.JOYPAD_MOTION,
					event.device,
					event.axis,
					1 if event.axis_value > 0 else -1
				]
			else:
				return
		else:
			return

		if ControlUtil.binding_alias_already_exists(currentButton.id, 0, result):
			return
		PlayerSettings.keybindings[currentButton.id][0] = result
		setNewTextAndReset()
	
func reset():
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null

func setNewTextAndReset():
	currentButton.text = ControlUtil.get_formatted_string(currentButton.id)
	SettingsSaver.override_keybindings(currentButton.id)
	currentButton = null
