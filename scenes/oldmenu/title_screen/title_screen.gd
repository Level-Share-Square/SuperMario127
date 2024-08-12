extends Screen

onready var button_start : Button = $ButtonStart

func _ready() -> void:
	# warning-ignore: return_value_discarded
	button_start.connect("pressed", self, "on_button_start_pressed")

func on_button_start_pressed() -> void:
	emit_signal("screen_change", "title_screen", "main_menu_screen")
