extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	connect("pressed", self, "_button_pressed")

func _button_pressed():
	Singleton.MenuVariables.quit_to_menu()
