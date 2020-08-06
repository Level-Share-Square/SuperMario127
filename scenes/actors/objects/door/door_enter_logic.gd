#Note: when the enter or exit animation starts, it sets the characters controllable and invulnerable variables, make sure to set them back in the parent code
extends Node2D

signal door_animation_finished

onready var area2d : Area2D = $Area2D
onready var tween : Tween = $Tween
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var door_sprite : AnimatedSprite = $DoorSprite
onready var timer : Timer = $Timer

onready var collision_width : float = $Area2D/CollisionShape2D.shape.extents.x

export var open_audio : AudioStream
export var close_audio : AudioStream

const DOOR_BOTTOM_DISTANCE := 35

export (float) var slide_to_center_length := 0.5
export (float) var entering_door_length := 1.0 
export (float) var exiting_door_length := 1.0

var is_idle := true

var stored_character : Character

func _physics_process(_delta : float) -> void:
	if is_idle:
		#the area2d is set to only collide with characters, so we can (hopefullY) safely assume if there 
		#is a collision it's with a character
		for body in area2d.get_overlapping_bodies(): 
			if body.name.begins_with("Character") and global_rotation == 0 and body.is_grounded() and body.get_input(Character.input_names.interact, true):
				start_door_enter_animation(body)

func start_door_ground_pound_animation(_character : Character) -> void:
	pass #to be implemented

func start_door_enter_animation(character : Character) -> void:
	stored_character = character 

	is_idle = false

	character.invulnerable = true 
	character.controllable = false
	character.movable = false
	character.sprite.rotation = 0
	
	character.sprite.animation = "enterDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	
	animate_door("open")

	var slide_length : float = slide_to_center_length

	#calculate the amount of time it should take based on the players distance from the center
	var distance_from_center_normalized : float = abs((character.position.x - global_position.x)) / collision_width 
	distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
	slide_length = slide_to_center_length * distance_from_center_normalized

	tween.interpolate_property(character, "position:x", null, global_position.x, slide_length)
	tween.interpolate_callback(character.anim_player, slide_length, "play", "enter_door")

	tween.start()
	
	character.anim_player.connect("animation_finished", self, "character_animation_finished")
	
func character_animation_finished(animation : String):
	# this is so the door closes after mario enters
	animate_door("close")
	
func animate_door(animation : String = "close"):
	# this function just plays the door animation, so code doesn't have to repeat
	door_sprite.animation = animation
	door_sprite.playing = true
	audio_player.stream = open_audio if animation == "open" else close_audio
	audio_player.play()

func start_door_exit_animation(character : Character) -> void:
	stored_character = character

	is_idle = false	

	character.invulnerable = true 
	character.controllable = false
	character.movable = false

	#this next line is kinda janky but hopefully it should set the animation after the above property
	#finishes animating, basically it has duration 0 and a delay the same length as the duration of the above line
	tween.interpolate_property(character.sprite, "animation", null, "doorExit" + \
			("Right" if character.facing_direction == 1 else "Left"), 0, 0, 2, exiting_door_length)

	tween.start()

func _tween_all_completed() -> void:
	emit_signal("door_animation_finished", stored_character)	

	stored_character = null
