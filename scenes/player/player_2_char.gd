extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value

export var value = 1

var value_to_names = [
	"M",
	"L"
]

func _ready():
	value = Singleton.PlayerSettings.player2_character
	value_text.text = value_to_names[value]
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")
	
func decrease_value():
	value -= 1
	if value < 0:
		value = 1
	value_text.text = value_to_names[value]
	
func increase_value():
	value += 1
	if value > 1:
		value = 0
	value_text.text = value_to_names[value]
