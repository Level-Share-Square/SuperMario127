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
			for children in get_children():
				if !children.get_name() in ignore_children:
					var button : Button = children.get_node("KeyButton")
					var viewport_size = button.get_viewport_rect().size
					var delta = viewport_size - button.get_local_mouse_position()
					if delta.x >= 0 && delta.y >= 0 && delta.x <= viewport_size.x && delta.y <= viewport_size.y:
						return
					
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
