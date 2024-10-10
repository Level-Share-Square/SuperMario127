extends TouchCheck


func _check() -> bool:
	._check()
	return character.is_grounded()
