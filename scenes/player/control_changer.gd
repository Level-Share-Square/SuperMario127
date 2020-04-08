extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value

func _ready():
	value_text.text = str(PlayerSettings.control_mode + 1)
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")
	
func decrease_value():
	PlayerSettings.control_mode -= 1
	if PlayerSettings.control_mode < 0:
		PlayerSettings.control_mode = 2
	value_text.text = str(PlayerSettings.control_mode + 1)
	
func increase_value():
	PlayerSettings.control_mode += 1
	if PlayerSettings.control_mode > 2:
		PlayerSettings.control_mode = 0
	value_text.text = str(PlayerSettings.control_mode + 1)
