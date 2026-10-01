extends Decoration

func _object_ready():
	._object_ready()
	$StaticBody2D.set_collision_layer_bit(0, is_enabled_and_on_ground())
