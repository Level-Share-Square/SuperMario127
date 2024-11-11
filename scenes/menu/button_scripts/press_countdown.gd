extends Node

signal text_changed
signal pressed

enum TextStyle {left, right, replace}

onready var button: Button = get_parent()
onready var initial_text: String = button.text

export (TextStyle) var countdown_style = TextStyle.left
export var countdown_time: int = 5
var count: float = -1

func _ready():
	button.connect("button_down", self, "button_down")
	button.connect("button_up", self, "button_up")

func _physics_process(delta):
	if count < 0: return
	
	count -= delta * 3 # made it faster cuz it feels better
	
	update_text(count)
	if count <= 0:
		count = -1
		
		emit_signal("pressed")
		button_up()

func update_text(number: float):
	var last_text = button.text
	
	var count_text: String = "[" + str(ceil(number)) + "]"
	match countdown_style:
		TextStyle.left:
			button.text = count_text + " " + initial_text
		TextStyle.right:
			button.text = initial_text + " " + count_text
		TextStyle.replace:
			button.text = count_text
	
	if button.text != last_text:
		emit_signal("text_changed")

func button_down():
	if Input.is_action_pressed("skip_count"):
		count = 0.01
	else:
		count = countdown_time

func button_up():
	count = -1
	
	button.text = initial_text
	emit_signal("text_changed")
