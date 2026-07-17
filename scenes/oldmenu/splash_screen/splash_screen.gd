extends Screen


func _ready():
	if LocalSettings.load_setting("General", "dark_mode", false):
		self.self_modulate = Color(0,0,0)

# very simple, just immediately smoothly transition to the main_menu screen when this screen is opened
func _open_screen():
	emit_signal("screen_change", "splash_screen", "main_menu_screen")
