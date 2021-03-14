extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var controls_options = get_parent().get_parent()
onready var player_selector_manager = controls_options.get_node("PlayerSelectors")
onready var binding_options = controls_options.get_node("ControlBindingWindow")

export var id : String

var last_hovered

func _ready():
	text = ControlUtil.get_formatted_string(id, 0)

func _gui_input(event):
	if event is InputEventMouseButton && event.pressed && !binding_options.is_open():
		if event.button_index == BUTTON_LEFT:		
			if controls_options.currentButton != null:
				controls_options.currentButton.text = controls_options.oldText
				controls_options.currentButton = null
				return
			
			controls_options.currentButton = self
			controls_options.oldText = text
			text = "Wait..."
		elif event.button_index == BUTTON_RIGHT:
			controls_options.reset()
			click_sound.play()
			
			var extra_bindings_container = binding_options.get_node("Contents").get_node("ScrollContainer").get_node("BindingBoxContainer")
			
			# Set key id
			extra_bindings_container.id = id
			
			# Clear old key bindings
			for children in extra_bindings_container.get_children():
				children.queue_free()
				
			# Instantiate new ones
			var extra_keybinding = load("res://scenes/player/window/controlbindingwindow/ControlBinding.tscn")
			
			for index in range(0, Singleton.PlayerSettings.keybindings[player_selector_manager.player_id()][id].size() + 1): # +1 for new binding option
				var extra_keybinding_instance = extra_keybinding.instance()
				extra_keybinding_instance.get_node("KeyButton").index = index
				extra_bindings_container.add_child(extra_keybinding_instance)
			
			binding_options.open()
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
