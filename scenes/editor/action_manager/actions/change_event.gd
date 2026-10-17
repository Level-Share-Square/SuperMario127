extends Action
class_name ChangeEventAction

var event: Event
var new_properties: Dictionary

var old_properties: Dictionary

func _do() -> void:
	old_properties = event.properties.duplicate(true)
	event.properties = new_properties.duplicate(true)
	
func _undo() -> void:
	event.properties = old_properties.duplicate(true)
