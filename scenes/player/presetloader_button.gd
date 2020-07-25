extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var controls_options = get_parent().get_parent()

var last_hovered
	
func _pressed():
	click_sound.play()
	
	var selector = get_parent().get_node("Selector")
	PlayerSettings.keybindings = ControlPresets.presets[selector.text]
	
	controls_options.currentButton = null
	
	for children in get_parent().get_parent().get_children():
		if children != get_parent():
			var button : Button = children.get_node("KeyButton")
			var keybindings = PlayerSettings.keybindings[button.id]
			
			button.text = str(OS.get_scancode_string(keybindings[0] if typeof(keybindings) == TYPE_ARRAY else keybindings))
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
