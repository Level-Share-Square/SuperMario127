extends State

class_name SlideState

export var divePower: Vector2 = Vector2(1350, 75)
var sliding = false
onready var sprite = character.get_node("AnimatedSprite")
onready var divePlayer = character.get_node("JumpSoundPlayer")

func _startCheck(delta):
	return false

func _start(delta):
	pass

func _update(delta):
	pass

func _stopCheck(delta):
	return false
