extends TextureButton

onready var bounds_control : Node2D = $"../.."

func _ready() -> void:
	# warning-ignore: return_value_discarded
	connect("pressed",self,"button_pressed")
	
func _input(_event) -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		rect_scale.x = 1.5
	else:
		rect_scale.x = 1
	
func button_pressed() -> void:
	var amount := 1 if name=="Out" else -1
	if(Input.is_key_pressed(KEY_SHIFT)):
		amount *= 10
		
	bounds_control.call("extend_bounds_"+get_parent().name,amount)
