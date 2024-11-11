extends Control

export var follow_path: NodePath
onready var follow: Control = get_node(follow_path)

export var parallax_factor: float = 0
export var lerp_speed: float = 0

func _process(delta):
	rect_position.y = lerp(
		rect_position.y,
		follow.rect_position.y * parallax_factor,
		delta * lerp_speed
	)
