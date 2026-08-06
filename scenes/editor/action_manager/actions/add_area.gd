extends BaseAreaAction
class_name AddAreaAction

func _do():
	create_area()
	
func _undo():
	delete_area()
