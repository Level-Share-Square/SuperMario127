extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var fps_cap = 3

func _ready():
	fps_cap = (Engine.target_fps / 10) - 3
	value_text.text = str(Engine.target_fps)
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")

func decrease_value():
	fps_cap -= 1
	if fps_cap < 0:
		fps_cap = 3
	process()

func increase_value():
	fps_cap += 1
	if fps_cap > 3:
		fps_cap = 0
	process()

func process():
	Engine.target_fps = 10 * (fps_cap + 3)
	value_text.text = str(Engine.target_fps)
