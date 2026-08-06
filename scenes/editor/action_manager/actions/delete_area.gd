extends BaseAreaAction
class_name DeleteAreaAction

func _do():
	delete_area()
	
func _undo():
	create_area()
