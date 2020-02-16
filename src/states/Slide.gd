extends State

class_name SlideState

onready var sprite = character.get_node("AnimatedSprite")
onready var divePlayer = character.get_node("JumpSoundPlayer")

func _startCheck(delta):
	return false

func _start(delta):
	character.friction = 2.25
	pass

func _update(delta):
	print_debug("a")
	pass

func _stop(delta):
	character.friction = 7.5

func _stopCheck(delta):
	return abs(character.velocity.x) < 5 or Input.is_action_just_pressed("jump")
