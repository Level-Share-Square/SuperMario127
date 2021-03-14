extends Screen

export (Array, NodePath) var ignore_children
export (Array, NodePath) var menu_buttons

onready var player_selector_manager = get_node("PlayerSelectors")
onready var title_only = get_node("TitleOnly")
onready var back_button = get_node("TitleOnly/Bottom/BackButton")

var control_info := [
	#   ID       label        
	[ "left", "Move Left" ],
	[ "right", "Move Right" ],
	[ "up", "Move Up" ],
	[ "down", "Move Down" ],
	[ "jump", "Jump" ],
	[ "dive", "Dive" ],
	[ "spin", "Spin" ],
	[ "gp", "Ground Pound" ],
	[ "gpcancel", "GP Cancel" ],
	[ "fludd", "Use Fludd" ],
	[ "nozzles", "Switch Nozzles" ],
	[ "crouch", "Crouch" ],
	[ "interact", "Interact" ],
]
const ROW_COUNT := 5
const X_START := 0
const X_STEP := 244
const Y_START := 140
const Y_STEP := 38


var currentButton : Button
var oldText : String

func _ready():
	# Prepare Presets
	var presetSelector = $"Preset Selection/Selector"
	for preset in ControlPresets.presets:
		presetSelector.add_item(preset)
	
	# Create control options
	var template_scene := ResourceLoader.load("res://scenes/player/control_template.tscn")
	var x := X_START
	var y := Y_START
	var y_index := 0
	for info_array in control_info:
		# Create an instance and set it up
		var instance : Control = template_scene.instance()
		instance.rect_position = Vector2(x, y)
		instance.name = info_array[1]
		instance.get_node("Label").text = info_array[1] + ":"
		instance.get_node("KeyButton").id = info_array[0]
		add_child(instance)
		
		# Increment position
		y += Y_STEP
		
		y_index += 1
		if y_index >= ROW_COUNT:
			# go up and right
			y_index = 0
			y = Y_START
			x += X_STEP
	
	# Fix z index of the control binding window
	move_child($ControlBindingWindow, get_child_count() - 1)
	
	# Title screen stuff
	if "mode" in get_tree().get_current_scene():
		title_only.queue_free()
	else:
		back_button.connect("pressed", self, "go_back")

func go_back():
	emit_signal("screen_change", "controls_screen", "options_screen")

func _input(event):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
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

		if ControlUtil.binding_alias_already_exists(currentButton.id, player_selector_manager.player_id(), 0, result):
			return
		Singleton.PlayerSettings.keybindings[player_selector_manager.player_id()][currentButton.id][0] = result
		set_new_text_and_reset()
	
func reset():
	if currentButton != null:
		currentButton.text = oldText
		currentButton = null

func set_new_text_and_reset():
	currentButton.text = ControlUtil.get_formatted_string(currentButton.id, player_selector_manager.player_id())
	SettingsSaver.override_keybindings(currentButton.id, player_selector_manager.player_id())
	currentButton = null
