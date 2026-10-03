extends TouchScreenButton


func _ready():
	connect("pressed", self, "pressed")


func _physics_process(delta):
	visible = Singleton.ModeSwitcher.visible and Singleton.ModeSwitcher.playtesting


func pressed():
	if Singleton.ModeSwitcher.visible:
		Singleton.ModeSwitcher.pressed(true, true)
