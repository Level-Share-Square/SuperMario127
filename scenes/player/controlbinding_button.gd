extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var controls_options = get_parent().get_parent()
onready var binding_options = controls_options.get_node("ControlBindingSettings")

export var id : String

var last_hovered

func _ready():
	var keybindings = PlayerSettings.keybindings[id]
	text = str(OS.get_scancode_string(keybindings[0] if typeof(keybindings) == TYPE_ARRAY else keybindings))

func _gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == BUTTON_LEFT:		
			if controls_options.currentButton != null:
				controls_options.currentButton.text = controls_options.oldText
				controls_options.currentButton = null
				return
			
			controls_options.currentButton = self
			controls_options.oldText = text
			text = "Wait..."
		elif event.button_index == BUTTON_RIGHT:
			click_sound.play()
			binding_options.open()
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
