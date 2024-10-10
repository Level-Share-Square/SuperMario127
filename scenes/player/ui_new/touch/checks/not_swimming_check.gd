extends TouchCheck


func _check() -> bool:
	._check()
	if is_instance_valid(character.state):
		return character.state.name != "SwimmingState"
	return true
