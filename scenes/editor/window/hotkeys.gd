extends Control


onready var hotkey_parent = $ScrollContainer/HBoxContainer/VBoxContainer
onready var label = $ScrollContainer/HBoxContainer/VBoxContainer2/Label
onready var timerlabel = $Label
onready var settings = $Settings
var hotkeys = {}
var timer = 600
var timer_run = false
var keycode: int
var inputevent: InputEvent
var hotkey


# Called when the node enters the scene tree for the first time.
func _ready():
	settings.connect("button_down", self, "settings_pressed")
	inputevent = null
	hotkey = null
	for i in hotkey_parent.get_children():
		i.connect("button_down", self, i.name + "_pressed", [i.name])
		var action_name = i.name
		hotkeys[action_name] = InputMap.get_action_list(action_name)[0]
		i.text = InputMap.get_action_list(action_name)[0].as_text()
		label.text += i.full_name + "\n"

func _input(event):
	if event is InputEventKey && timer >= 0 && timer < 600:
		inputevent = event
	
func _process(delta):
	if timer_run == true:
		timerlabel.visible = true
		timerlabel.text = String(round(timer * delta))
		timer -= 1
		if inputevent != null:
			InputMap.action_erase_events(hotkey)
			InputMap.action_add_event(hotkey, inputevent)
			print(InputMap.get_action_list(hotkey))
			inputevent = null
			hotkey = null
			for i in hotkey_parent.get_children():
				var action_name = i.name
				i.text = InputMap.get_action_list(action_name)[0].as_text()
			timer = 1000
			timer_run = false
		if timer < 0:
			timer = 1000
			timer_run = false
	else:
		timerlabel.visible = false
		inputevent = null
		hotkey = null
	
func toggle_grid_pressed(inputname):
	hotkey = inputname
	timer = 600
	timer_run = true
	
func settings_pressed():
	hide()
	get_parent().get_node("LevelSettings").show()
