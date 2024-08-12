extends Node

signal pressed

onready var button: Button = get_parent()
onready var initial_text: String = button.text

export var countdown_time: int = 5
var count: float = -1

func _ready():
	button.connect("button_down", self, "button_down")
	button.connect("button_up", self, "button_up")

func _physics_process(delta):
	if count < 0: return
	
	count -= delta
	button.text = str(
		ceil(
			abs(count)
		)
	)
	
	if count <= 0:
		count = -1
		emit_signal("pressed")


func button_down():
	count = countdown_time

func button_up():
	count = -1
	button.text = initial_text
