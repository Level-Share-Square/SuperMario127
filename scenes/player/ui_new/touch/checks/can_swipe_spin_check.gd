extends TouchCheck


export var max_priority: int = 2


func _check() -> bool:
	._check()
	if is_instance_valid(character.state):
		return character.state.priority <= max_priority
	return true
