extends TouchCheck


onready var button := get_parent()


func _check() -> bool:
	._check()
	return is_instance_valid(character.nozzle) and character.fuel >= 0 and character.stamina >= 0


func _physics_process(_delta):
	if button.is_pressed and not _check():
		button.set_pressed(false)
