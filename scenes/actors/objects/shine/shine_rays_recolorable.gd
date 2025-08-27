tool
extends Node2D


export var shine_path: NodePath
onready var shine_sprite: GameObject = get_node(shine_path)


func _process(_delta):
	if is_instance_valid(shine_sprite) and shine_sprite.color != shine_sprite.NORMAL_COLOR:
		modulate = shine_sprite.color
