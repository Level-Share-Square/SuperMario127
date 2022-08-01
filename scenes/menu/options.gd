extends Screen

onready var controls_button = $Page1/ControlsButton
onready var back_button = $TitleOnly/Bottom/BackButton

func _ready():
	var _connect = back_button.connect("pressed", self, "go_back")
	_connect = controls_button.connect("pressed", self, "open_controls")

func go_back():
	emit_signal("screen_change", "options_screen", "main_menu_screen")

func open_controls():
	emit_signal("screen_change", "options_screen", "controls_screen")
