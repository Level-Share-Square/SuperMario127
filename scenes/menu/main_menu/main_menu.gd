extends Screen

onready var button_levels : Button = $CenterContainer/VBoxContainer/ButtonLevels
onready var button_options : Button = $CenterContainer/VBoxContainer/ButtonOptions
onready var button_quit : Button = $CenterContainer/VBoxContainer/ButtonQuit

func _ready() -> void:
	var _connect 
	_connect = button_levels.connect("pressed", self, "on_button_levels_pressed")
	_connect = button_options.connect("pressed", self, "on_button_options_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")

func on_button_levels_pressed() -> void:
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_options_pressed() -> void:
	emit_signal("screen_change", "main_menu_screen", "shine_select_screen")

func on_button_quit_pressed() -> void:
	get_tree().quit()

