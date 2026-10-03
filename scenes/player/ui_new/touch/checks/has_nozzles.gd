extends TouchCheck


onready var button := get_parent()


func _check() -> bool:
	._check()
	return is_instance_valid(CurrentLevelData.vars) and CurrentLevelData.vars.nozzles_collected.size() > 1


func _physics_process(_delta):
	button.visible = _check()
