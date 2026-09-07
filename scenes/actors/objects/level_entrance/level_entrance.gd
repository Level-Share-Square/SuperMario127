extends Teleporter


### PROPERTIES

func _init():
	tag = "_entrance"

func start_exit_animation(character: Character) -> void:
	.start_exit_animation(character)
	character.show()
	emit_signal("exit_completed")


func is_level_entrance() -> bool:
	return true
