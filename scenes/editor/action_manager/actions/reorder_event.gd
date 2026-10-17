extends Action
class_name ReorderEventAction

var events: Array
var old_index: int
var new_index: int

func swap(old: int, new: int) -> void:
	var event = events.pop_at(old)
	events.insert(new, event)

func _do():
	swap(old_index, new_index)
	
func _undo():
	swap(new_index, old_index)
