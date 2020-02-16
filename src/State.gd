extends Resource
class_name State

var name: String
var character: Character

func handleUpdate(delta: float):
	if character.controllable:
		if character.state != self and _startCheck(delta):
			character.set_state(self, delta)
		if character.state == self:
			_update(delta)
		if character.state == self and _stopCheck(delta):
			character.set_state(null, delta)
	_generalUpdate(delta)
func _startCheck(delta: float):
	pass
	
func _start(delta: float):
	pass
	
func _update(delta: float):
	pass
	
func _stopCheck(delta: float):
	pass
	
func _stop(delta: float):
	pass
	
func _generalUpdate(delta: float):
	pass
