extends TouchCheck


const PLAYER_ID: int = 0
export var test_multiplier: float = 1

export var cooldown_time: float
var cooldown_timer: float


func _input(event):
	._check()
	if character.is_grounded() or character.is_on_wall():
		cooldown_timer = cooldown_time


func _physics_process(delta):
	cooldown_timer -= delta


func _check() -> bool:
	._check()
	
	if is_instance_valid(character.state):
		if character.state.name == "SwimmingState":
			return true
		
	return cooldown_timer <= 0 and not character.will_collide(test_multiplier)
