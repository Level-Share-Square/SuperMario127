extends Node

export (Array, NodePath) var ignore_children

var currentButton : Button
var oldText : String

func _ready():
	# Prepare Keybindings
	for children in get_children():
		if !(children.get_name() in ignore_children):
			var button : Button = children.get_node("KeyButton")
			var keybindings = PlayerSettings.keybindings[button.id]
			
			button.text = str(OS.get_scancode_string(keybindings[0] if typeof(keybindings) == TYPE_ARRAY else keybindings))
			# warning-ignore: return_value_discarded
			button.connect("pressed", self, "button_pressed", [button])
		
	# Prepare Presets
	var presetSelector = $"Preset Selection/Selector"
	for preset in ControlPresets.presets:
		presetSelector.add_item(preset)
		
func _input(event):
	if event is InputEventKey && event.pressed && currentButton != null:
		currentButton.text = OS.get_scancode_string(event.scancode)
		PlayerSettings.keybindings[currentButton.id] = event.scancode
		currentButton = null
		
func button_pressed(button : Button):
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null
		
		return
	
	currentButton = button
	oldText = button.text
	button.text = "Wait..."
	
func reset():
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null
