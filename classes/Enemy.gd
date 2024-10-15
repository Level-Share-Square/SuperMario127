class_name Enemy
extends GameObject

export var body_path : NodePath
export var components_path : NodePath

onready var body : PhysicsBody2D = get_node(body_path)
onready var components : = get_node(components_path)

func _ready():
	pass
