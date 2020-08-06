extends Node

var id : String

var currentButton : Button
var oldText : String
var shouldCreateNewBindingOption = false

onready var window = get_parent().get_parent().get_parent()
onready var controls_options = window.get_parent()
onready var close_button = get_parent().get_parent().get_parent().get_node("CloseButton")

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
			if event.button_index == BUTTON_LEFT:
				for children in currentButton.get_parent().get_parent().get_children():
					var button : Button = children.get_node("KeyButton")
					if button.is_hovered():
						return
				
				if close_button.is_hovered():
					reset()
					return
				
				var real_rect = Rect2(window.get_rect().position, window.get_rect().size * window.rect_scale)
				
				if !real_rect.has_point(event.position):
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
		
		if ControlUtil.binding_alias_already_exists(id, currentButton.index, result):
			return
		if currentButton.index == PlayerSettings.keybindings[id].size():
			PlayerSettings.keybindings[id].resize(PlayerSettings.keybindings[id].size()+1)
			shouldCreateNewBindingOption = true
			currentButton.get_parent().get_node("DeleteButton").visible = true
		
		PlayerSettings.keybindings[id][currentButton.index] = result
		setNewTextAndReset()
	
func reset():
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null

func setNewTextAndReset():
	currentButton.get_parent().get_node("DeviceInfoLabel").text = ControlUtil.get_device_info(id, currentButton.index)
	currentButton.text = ControlUtil.get_formatted_string_by_index(id, currentButton.index)
	if currentButton.index == 0:
		for children in controls_options.get_children():
				if !children.get_name() in controls_options.ignore_children:
					var button : Button = children.get_node("KeyButton")
					if button.id == id:
						button.text = currentButton.text
						break			
		
	SettingsSaver.override_keybindings(id)
	currentButton = null
	
	if shouldCreateNewBindingOption:
		shouldCreateNewBindingOption = false
		
		var extra_keybinding = load("res://scenes/player/window/controlbindingwindow/ControlBinding.tscn")
		var extra_keybinding_instance = extra_keybinding.instance()
		extra_keybinding_instance.get_node("KeyButton").index = PlayerSettings.keybindings[id].size()
		add_child(extra_keybinding_instance)
