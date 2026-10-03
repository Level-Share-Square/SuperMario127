extends State

class_name ExitPaintingState

# wait a bit before letting mario leave the state, to fix a bug
var cancel_wait: int = 0

func _init():
	priority = 5

func _start_check(_delta):
	return false

func _start(_delta):
	character.sprite.animation = "shineFall"
	cancel_wait = 4

func _update(_delta):
	cancel_wait -= 1

func _stop(_delta):
	pass 

func _stop_check(_delta):
	return character.is_grounded() and cancel_wait <= 0
