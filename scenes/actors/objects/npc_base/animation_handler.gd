extends Node2D


export var head_offsets: Dictionary

onready var head = $Head
onready var body = $Body

var head_anim: String
var body_anim: String


func _process(delta):
	head.position = head_offsets[body_anim][body.frame]
	
	head.offset = Vector2.ZERO
	head.rotation_degrees = 0
	
	if head_anim == "confused":
		head.rotation_degrees = 10
		head.offset = Vector2(1, 0)
	
	if head_anim == "raging":
		head.modulate = lerp(head.modulate, Color.red, delta)
		head.offset = Vector2(
			rand_range(-1.0, 1.0),
			rand_range(0, 2.0)
		)
	else:
		head.modulate = lerp(head.modulate, Color.white, delta * 4)


func play_expression(animation: String):
	head_anim = animation
	head.play(animation)


func play_action(animation: String):
	body_anim = animation
	body.play(animation)
