extends Control

onready var left = $Left
onready var right = $Right
onready var value_text = $Value

export var value = 1

func _ready():
	value = Singleton.PlayerSettings.number_of_players
	value_text.text = str(value)
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")
	
func decrease_value():
	value -= 1
	if value < 1:
		value = 2
	value_text.text = str(value)
	
func increase_value():
	value += 1
	if value > 2:
		value = 1
	value_text.text = str(value)
