extends HBoxContainer


onready var x = $"%X"
onready var y = $"%Y"



func load_object_value() -> void:
	var value: Vector2 = get_property_in_object()
	
	x.text = str(value.x)
	y.text = str(value.y)
