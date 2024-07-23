extends Control


onready var hotkey_parent = $ScrollContainer/HBoxContainer/VBoxContainer
onready var label = $ScrollContainer/HBoxContainer/VBoxContainer2/Label
onready var timerlabel = $Label
onready var settings = $Settings
onready var reset = $Reset
var hotkeys = {}
var timer = 600
var timer_run = false
var keycode: int
var inputevent: InputEvent
var hotkey


# Called when the node enters the scene tree for the first time.
func _ready():
	if "LevelSettingsWindow" in str(get_parent()):
		hide()
	else:
		show()
	var file = File.new()
	if file.file_exists("user://hotkeys/hotkeys.file"):
		file.open("user://hotkeys/hotkeys.file", File.READ)
		load_hotkeys(file.get_var())
		file.close()
	settings.connect("button_down", self, "settings_pressed")
	reset.connect("button_down", self, "reset_pressed")
	inputevent = null
	hotkey = null
	var j = 0
	for i in hotkey_parent.get_children():
		if "LevelSettingsWindow" in str(get_parent()):
			if Singleton2.editor_hotkeys.has(i.name):
				print(i)
				i.show()
				var action_name = i.name
				hotkeys[action_name] = InputMap.get_action_list(action_name)[0]
				i.text = InputMap.get_action_list(action_name)[0].as_text()
				label.text += i.full_name + "\n"
				i.connect("button_down", self, "button_pressed", [i.name])
			else:
				i.hide()
				
		else:
			if Singleton2.player_hotkeys.has(i.name):
				settings.hide()
				reset.hide()
				i.show()
				var action_name = i.name
				hotkeys[action_name] = InputMap.get_action_list(action_name)[0]
				i.text = InputMap.get_action_list(action_name)[0].as_text()
				label.text += i.full_name + "\n"
				i.connect("button_down", self, "button_pressed", [i.name])
			else:
				i.hide()

func _input(event):
	if event is InputEventKey && timer >= 0 && timer < 600:
		inputevent = event
	
func _physics_process(delta):
	timerlabel.text = String(round(timer * delta))
	if timer_run == true:
		timerlabel.visible = true
		timer -= 1
		if inputevent != null:
			InputMap.action_erase_events(hotkey)
			InputMap.action_add_event(hotkey, inputevent)
			inputevent = null
			hotkey = null
			hotkeys.clear()
			for i in hotkey_parent.get_children():
				var action_name = i.name
				i.text = InputMap.get_action_list(action_name)[0].as_text()
				hotkeys[action_name] = InputMap.get_action_list(action_name)[0]
			timer = 1000
			save_hotkeys()
			timer_run = false
		if timer < 0:
			timer = 1000
			timer_run = false
	else:
		timerlabel.visible = false
		inputevent = null
		hotkey = null
	
func button_pressed(inputname):
	hotkey = inputname
	timer = 600
	timer_run = true
	
func load_hotkeys(hotkey_dict: Dictionary):
	var dict = {}
	for i in hotkey_dict:
		var input = InputEventKey.new()
		input.set_scancode(hotkey_dict[i])
		dict[i] = input
	for i in dict:
		InputMap.action_erase_events(i)
		InputMap.action_add_event(i, dict[i])
	for i in hotkey_parent.get_children():
		var action_name = i.name
		i.text = InputMap.get_action_list(action_name)[0].as_text()
	save_hotkeys()
	
func settings_pressed():
	hide()
	get_parent().get_node("LevelSettings").show()
	Singleton2.disable_hotkeys = false
	
func reset_pressed():
	var file = File.new()
	file.open("user://hotkeys/defhotkeys.file", File.READ)
	var result = file.get_var()
	print(result)
	load_hotkeys(result)
	file.close()
	
func save_hotkeys():
	var file = File.new()
	file.open("user://hotkeys/hotkeys.file", File.WRITE)
	var dict = {}
	for i in hotkeys:
		dict[i] = InputMap.get_action_list(i)[0].get_scancode()
	file.store_var(dict)
	file.close()
	
