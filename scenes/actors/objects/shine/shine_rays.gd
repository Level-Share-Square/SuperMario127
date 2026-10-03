tool
extends ColorRect


export var ray_rotation_speed: float = 0.6
export var ray_distance: float = 0.4

var ray_rotation: float = 0


func _process(delta):
	ray_rotation += ray_rotation_speed * delta
	ray_rotation = wrapf(ray_rotation, 0, 2 * PI)
	
	material.set_shader_param("ray_distance", ray_distance)
	material.set_shader_param("rotation", ray_rotation)
