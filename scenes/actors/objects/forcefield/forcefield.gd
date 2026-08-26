extends BoxBase

onready var effect = $Shockwave/Effect


func _ready():
	break_animation.play("pulse")
	effect.material = effect.material.duplicate()


func _process(delta):
	if not effect.is_visible_in_tree(): return
	
	var scale_vector: Vector2 = sprite.rect_size / default_size
	var scale_factor: float = (scale_vector.x + scale_vector.y)/2
	
	effect.material.set_shader_param("scale", scale_factor)
	effect.material.set_shader_param("global_position", get_canvas_transform().xform(global_position))
