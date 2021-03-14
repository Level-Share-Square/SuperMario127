extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value

func _ready():
	value_text.text = str(Singleton.PlayerSettings.control_mode + 1)
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")
	
func decrease_value():
	Singleton.PlayerSettings.control_mode -= 1
	if Singleton.PlayerSettings.control_mode < 0:
		Singleton.PlayerSettings.control_mode = 2
	process()
	
func increase_value():
	Singleton.PlayerSettings.control_mode += 1
	if Singleton.PlayerSettings.control_mode > 2:
		Singleton.PlayerSettings.control_mode = 0
	process()

func process():
	value_text.text = str(Singleton.PlayerSettings.control_mode + 1)
