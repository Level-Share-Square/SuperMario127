extends State

class_name SlideState

onready var sprite = character.get_node("AnimatedSprite")
onready var dive_player = character.get_node("JumpSoundPlayer")

func _start(delta):
	character.friction = 2.25

func _stop(delta):
	character.friction = 7.5

func _stop_check(delta):
	return abs(character.velocity.x) < 5 or Input.is_action_just_pressed("jump")
