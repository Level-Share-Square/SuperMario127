extends Teleporter


### PROPERTIES

func start_exit_animation(character: Character) -> void:
	character.show()
	finish_exit_animation(character)


func is_level_entrance() -> bool:
	return true
