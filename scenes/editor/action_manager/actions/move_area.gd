extends BaseAreaAction
class_name MoveAreaAction

var delta: int

func _do():
	move_area(area_id, delta)
	
func _undo():
	var new_id = area_id + delta
	var new_delta = delta * (-1)
	move_area(new_id, new_delta)
