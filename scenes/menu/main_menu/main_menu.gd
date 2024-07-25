extends Screen

onready var button_campaign : Button = $Panel/VBoxContainer/ButtonCampaign
onready var button_levels : Button = $Panel/VBoxContainer/ButtonLevels
onready var button_search : Button = $Panel/VBoxContainer/ButtonSearch
onready var button_templates : Button = $Panel/VBoxContainer/ButtonTemplates
onready var button_options : Button = $Panel/VBoxContainer/ButtonOptions
onready var button_quit : Button = $Panel/ButtonQuit
onready var button_login : Button = $Panel/ButtonLogin
onready var button_skip = $Control/Skip
onready var button_speed = $Control/Speed
onready var credits = $Control/AnimationPlayer
onready var credits2 = $Control/AnimationPlayer2
onready var credits3 = $Control/AnimationPlayer3
onready var error_window = $ErrorWindow

onready var timer = $CooldownTimer

onready var lss_icon = preload("res://assets/misc/LSS.svg")

const EDITOR_SCENE : PackedScene = preload("res://scenes/editor/editor.tscn")


func _ready() -> void:
	$Control/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if UserInfo.username != "":
		button_login.text = "Logged in as " + UserInfo.username
	Singleton2.crash = false
	if Singleton2.rp == true:
		update_activity()
	elif Singleton2.rp == false:
		if Singleton2.dead == false:
			Discord.queue_free()
			Singleton2.dead = true
		elif Singleton2.dead == true:
			pass
	var _connect = button_levels.connect("pressed", self, "on_button_levels_pressed")
	_connect = button_templates.connect("pressed", self, "on_button_templates_pressed")
	_connect = button_options.connect("pressed", self, "on_button_options_pressed")
	_connect = button_search.connect("pressed", self, "on_button_search_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")
	_connect = button_login.connect("pressed", self, "on_button_login_pressed")
	_connect = button_campaign.connect("pressed", self, "on_button_credits_pressed")
	_connect = button_skip.connect("pressed", self, "on_button_skip_pressed")
	_connect = button_speed.connect("pressed", self, "on_button_speed_pressed")
	
#func _on_button_login_pressed():
#	$LogInWindow.open()
#
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("On the Main Menu")

	var assets = activity.get_assets()
	assets.set_large_image("sm127")
	assets.set_large_text("0.8.0")
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

func on_button_search_pressed() -> void:
	emit_signal("screen_change", "main_menu_screen", "search_screen")
	
func _process(delta):
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
	
func on_button_speed_pressed() -> void:
	if credits.playback_speed == 1:
		button_speed.text = "Speed (1x)"
		credits.playback_speed = 5
	else:
		button_speed.text = "Speed (5x)"
		credits.playback_speed = 1
		
func on_button_skip_pressed() -> void:
	Singleton.Music.stop_temporary_music()
	credits.play("skip")
	$Control/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func on_button_credits_pressed() -> void:
	Singleton.Music.play_temporary_music(66, 50)
	credits3.play("Pasted Animation")
	credits.play("roll")
	var _connect = credits.connect("animation_finished", self, "on_roll_finished")
	credits2.play("button in")
	$Control/ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP

func on_roll_finished(anim_name):
	if anim_name == "roll":
		Singleton.Music.stop_temporary_music()
		$Control/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
