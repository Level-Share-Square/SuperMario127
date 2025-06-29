extends Teleporter


### PROPERTIES
func _set_properties() -> void:
	savable_properties = []
	editable_properties = []


func _set_property_values() -> void:
	pass


func _init():
	tag = "_entrance"


func start_exit_animation(character: Character) -> void:
	finish_exit_animation(character)
