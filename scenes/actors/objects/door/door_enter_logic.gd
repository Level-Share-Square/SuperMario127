#Note: when the enter or exit animation starts, it sets the characters controllable and invulnerable variables, make sure to set them back in the parent code
extends Node2D

signal start_door_logic

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
export (float) var entering_door_length := 0.75 
export (float) var exiting_door_length := 0.75

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
	
	# when mario finishes entering the door, trigger a function (one shot)
	character.anim_player.connect("animation_finished", self, "character_animation_finished", [character], CONNECT_ONESHOT)
	
func character_animation_finished(animation : String, character : Character):
	# this is so the door closes after mario enters
	animate_door("close")
	door_sprite.connect("animation_finished", self, "start_door_logic", [character], CONNECT_ONESHOT)

func start_door_logic(character : Character):
	# this is to make the door do stuff while mario is hidden
	emit_signal("start_door_logic", character)
	
func animate_door(animation : String = "close"):
	# this function just plays the door animation, so code doesn't have to repeat
	door_sprite.animation = animation
	door_sprite.playing = true
	audio_player.stream = open_audio if animation == "open" else close_audio
	audio_player.play()

func start_door_exit_animation(character : Character) -> void:
	# just plays a few animations
	stored_character = character
	
	is_idle = false	

	character.invulnerable = true 
	character.controllable = false
	character.movable = false
	
	animate_door("open")
	character.anim_player.play("exit_door")
	# when mario finishes exiting, run a function (one shot)
	character.anim_player.connect("animation_finished", self, "door_exit_anim_finished", [character], CONNECT_ONESHOT)

	tween.start()

func door_exit_anim_finished(animation : String, character : Character):
	# closes the door and gives back control to mario
	is_idle = true
	
	character.invulnerable = false 
	character.controllable = true
	character.movable = true

	character.sprite.animation = "exitDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	animate_door("close")

func _tween_all_completed() -> void:
	emit_signal("door_animation_finished", stored_character)	

	stored_character = null
