class_name CameraCutscene
extends Resource

enum Type {AUTO, PAN, TRANSITION}

export(Type) var cutscene_type = 0
export(int, "Ease In", "Ease Out", "Ease In-Out", "Ease Out-In") var tween_ease = 0
export(int, "Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back") var transition_type = 0
export(float) var time = 0.5
export(NodePath) var owner_path
export(String) var animation

var owner: Node
var to: Vector2


func set_up(owner_node: Node, new_to: Vector2):
	owner = owner_node
	to = new_to
