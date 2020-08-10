extends Screen

onready var main_menu_controller : Control = get_tree().current_scene

onready var button_play : Button = $CenterContainer/VBoxContainer/ButtonPlay
onready var button_options : Button = $CenterContainer/VBoxContainer/ButtonOptions
onready var button_quit : Button = $CenterContainer/VBoxContainer/ButtonQuit

func _ready() -> void:
	var _connect #pointless variable, just meant to accept the return values so i don't need to do warning ignore 4 times
	_connect = button_play.connect("pressed", self, "on_button_play_pressed")
	_connect = button_options.connect("pressed", self, "on_button_options_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")

func on_button_play_pressed() -> void:
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_options_pressed() -> void:
	pass

func on_button_quit_pressed() -> void:
	get_tree().quit()

