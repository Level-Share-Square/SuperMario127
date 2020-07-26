#Note: when the enter or exit animation starts, it sets the characters controllable and invulnerable variables, make sure to set them back in the parent code
extends Node2D

signal pipe_animation_finished

onready var area2d = $Area2D
onready var tween = $Tween

onready var collision_width = $Area2D/CollisionShape2D.shape.extents.x

const PIPE_BOTTOM_DISTANCE = 35

export (float) var slide_to_center_length = 1.0
export (float) var entering_pipe_length = 1.0 
export (float) var exiting_pipe_length = 1.0

var is_idle := true

var stored_character

func _physics_process(_delta):
	if is_idle:
		for body in area2d.get_overlapping_bodies(): #the area2d is set to only collide with characters, so we can (hopefullY) safely assume if there is a collision it's with a character
			if body.is_grounded() and body.inputs[body.input_names.crouch][body.input_params.just_pressed]:
				start_pipe_enter_animation(body)

func start_pipe_enter_animation(character):
	stored_character = character 

	is_idle = false

	character.invulnerable = true 
	character.controllable = false

	var slide_length = slide_to_center_length

	#calculate the amount of time it should take based on the players distance from the center
	var distance_from_center_normalized = abs((character.position.x - global_position.x) / collision_width) 
	if distance_from_center_normalized != 0: #prevent division by 0
		slide_length = slide_to_center_length / distance_from_center_normalized

	tween.interpolate_property(character, "position:x", null, global_position.x, slide_length)
	tween.interpolate_property(character, "position:y", null, global_position.y + PIPE_BOTTOM_DISTANCE, entering_pipe_length, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, slide_length)

	tween.start()

func start_pipe_exit_animation(character):
	stored_character = character

	is_idle = false	

	character.invulnerable = true 
	character.controllable = false

	tween.interpolate_property(character, "position:y", global_position.y + PIPE_BOTTOM_DISTANCE, global_position.y)

	tween.start()

func _tween_all_completed():
	emit_signal("pipe_animation_finished", stored_character)	

	stored_character = null