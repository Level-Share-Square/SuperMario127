extends Teleporter


### PROPERTIES

func _init():
	tag = "_entrance"

func start_exit_animation(character: Character) -> void:
	character.show()
	finish_exit_animation(character)


func is_level_entrance() -> bool:
	return true
