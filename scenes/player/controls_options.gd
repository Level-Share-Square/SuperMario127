extends Node

var currentButton : Button
var oldText : String

func _ready():
	var keybindings = PlayerSettings.keybindings
	for children in get_children():
		var button : Button = children.get_node("KeyButton")
		button.text = str(OS.get_scancode_string(keybindings[button.id]))
		button.connect("pressed", self, "button_pressed", [button])
		
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
