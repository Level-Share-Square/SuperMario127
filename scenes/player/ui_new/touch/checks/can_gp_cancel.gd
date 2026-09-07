extends TouchCheck


onready var button := get_parent()


func _check() -> bool:
	._check()
	return is_instance_valid(character.state) and character.state.name == "GroundPoundState"


func _physics_process(_delta):
	button.visible = _check()
