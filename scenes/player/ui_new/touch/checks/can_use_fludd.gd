extends TouchCheck


onready var button := get_parent()


func _check() -> bool:
	._check()
	return character.fuel >= 0 and character.stamina >= 0


func _physics_process(_delta):
	if button.pressed and not _check():
		button.pressed = false
