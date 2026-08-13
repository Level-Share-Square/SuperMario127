extends Area2D


export var lerp_speed: float = 10
export var offset: Vector2
export var char_path: NodePath

onready var character = get_node(char_path)


func _physics_process(delta):
	position = lerp(position, character.position + offset, delta * lerp_speed)
