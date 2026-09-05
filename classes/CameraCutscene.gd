class_name CameraCutscene
extends Resource

enum Type {AUTO, PAN, TRANSITION}

export(Type) var cutscene_type = 0
export(int, "Ease In", "Ease Out", "Ease In-Out", "Ease Out-In") var tween_ease = 0
export(int, "Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back") var transition_type = 0
export(float) var time = 0.5
export(float) var max_pan_distance = 800
export(bool) var do_time_scaling = true
export(bool) var do_pause = true
export(bool) var do_reverse = true
export(bool) var lock_movement = true
export(bool) var from_character = false
export(Array) var exclude_stoppers = []
export(NodePath) var owner_path
export(String) var animation

var owner: Node
var to: Vector2
var from := Vector2.INF


func set_up(owner_node: Node, new_to: Vector2, new_from: Vector2 = from):
	owner = owner_node
	to = new_to
	from = new_from
