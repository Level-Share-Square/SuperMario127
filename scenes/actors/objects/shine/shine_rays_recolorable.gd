tool
extends Node2D


export var ray_path: NodePath
onready var ray_sprite: Node2D = get_node(ray_path)


func _process(_delta):
	if is_instance_valid(ray_sprite):
		transform = ray_sprite.transform
		modulate.a = ray_sprite.modulate.a
