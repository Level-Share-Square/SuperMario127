extends Screen

onready var button_campaign : Button = $Panel/VBoxContainer/ButtonCampaign
onready var button_levels : Button = $Panel/VBoxContainer/ButtonLevels
onready var button_editor : Button = $Panel/VBoxContainer/ButtonEditor
onready var button_templates : Button = $Panel/VBoxContainer/ButtonTemplates
onready var button_quit : Button = $Panel/VBoxContainer/ButtonQuit

onready var timer = $CooldownTimer

const EDITOR_SCENE : PackedScene = preload("res://scenes/editor/editor.tscn")

func _ready() -> void:
	var _connect = button_levels.connect("pressed", self, "on_button_levels_pressed")
	_connect = button_editor.connect("pressed", self, "on_button_editor_pressed")
	_connect = button_templates.connect("pressed", self, "on_button_templates_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")

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
	if SavedLevels.is_template_list:
		SavedLevels.is_template_list = false
		# Prevents errors when swapping between level lists
		SavedLevels.selected_level = SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_editor_pressed() -> void:
	SavedLevels.selected_level = SavedLevels.NO_LEVEL
	get_node("/root/CurrentLevelData")._ready() # Reset level
	var _change_scene = get_tree().change_scene_to(EDITOR_SCENE)

func on_button_templates_pressed() -> void:
	if timer.time_left > 0:
		return
	if !SavedLevels.is_template_list:
		SavedLevels.is_template_list = true
		# Prevents errors when swapping between level lists
		SavedLevels.selected_level = SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_quit_pressed() -> void:
	get_tree().quit()

