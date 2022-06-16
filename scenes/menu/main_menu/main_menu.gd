extends Screen

onready var button_campaign : Button = $Panel/VBoxContainer/ButtonCampaign
onready var button_levels : Button = $Panel/VBoxContainer/ButtonLevels
onready var button_templates : Button = $Panel/VBoxContainer/ButtonTemplates
onready var button_options : Button = $Panel/VBoxContainer/ButtonOptions
onready var button_quit : Button = $Panel/ButtonQuit

onready var timer = $CooldownTimer

const EDITOR_SCENE : PackedScene = preload("res://scenes/editor/editor.tscn")

func _ready() -> void:
	if Singleton2.rp == true:
		update_activity()
	var _connect = button_levels.connect("pressed", self, "on_button_levels_pressed")
	_connect = button_templates.connect("pressed", self, "on_button_templates_pressed")
	_connect = button_options.connect("pressed", self, "on_button_options_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("On the Main Menu")

	var assets = activity.get_assets()
	assets.set_large_image("sm127")
	assets.set_large_text("0.7.2")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 1)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))


func _input(_event : InputEvent) -> void:
	if !can_interact or get_focus_owner() != null:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		button_quit.grab_focus()
	elif Input.is_action_just_pressed("ui_down"):
		button_campaign.grab_focus()
	elif Input.is_action_just_pressed("ui_left"):
		pass
	elif Input.is_action_just_pressed("ui_right"):
		pass

func on_button_levels_pressed() -> void:
	if timer.time_left > 0:
		return
	if Singleton.SavedLevels.is_template_list:
		Singleton.SavedLevels.is_template_list = false
		# Prevents errors when swapping between level lists
		Singleton.SavedLevels.selected_level = Singleton.SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_templates_pressed() -> void:
	if timer.time_left > 0:
		return
	if !Singleton.SavedLevels.is_template_list:
		Singleton.SavedLevels.is_template_list = true
		# Prevents errors when swapping between level lists
		Singleton.SavedLevels.selected_level = Singleton.SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_options_pressed() -> void:
	if timer.time_left > 0:
		return
	if !Singleton.SavedLevels.is_template_list:
		Singleton.SavedLevels.is_template_list = true
		# Prevents errors when swapping between level lists
		Singleton.SavedLevels.selected_level = Singleton.SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "options_screen")

func on_button_quit_pressed() -> void:
	get_tree().quit()

