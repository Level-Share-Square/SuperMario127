extends Node2D


onready var visibility_notifier = $"%VisibilityNotifier2D"

export var head_positions: Dictionary
export var expression_offsets: Dictionary
export var head_transforms: bool = true

export var raging_scale := 1.0

onready var head = $Head
onready var body = $Body

var head_anim: String
var body_anim: String

var is_preview: bool


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	head.position = head_positions[body_anim][body.frame]
	
	head.offset = Vector2.ZERO
	head.rotation_degrees = 0
	
	if head_transforms:
		if head_anim == "confused":
			head.rotation_degrees = 10
			head.offset = Vector2(1, 0)

		if head_anim == "raging":
			head.modulate = lerp(head.modulate, Color.red, delta)
			head.offset = Vector2(
				rand_range(-1.0, 1.0)*raging_scale,
				rand_range(0, 2.0)*raging_scale
			)
		else:
			head.modulate = lerp(head.modulate, Color.white, delta * 4)

		
	if head_anim in expression_offsets:
		head.offset = expression_offsets[head_anim]

func play_expression(animation: String):
	head_anim = animation
	head.play(animation)


func play_action(animation: String):
	body_anim = animation
	body.play(animation)
