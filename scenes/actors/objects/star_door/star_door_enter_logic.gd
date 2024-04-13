#Note: when the enter or exit animation starts, it sets the characters controllable and invulnerable variables, make sure to set them back in the parent code
extends Node2D

signal start_door_logic
signal exit

onready var area2d : Area2D = $Area2D
onready var tween : Tween = $Tween
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var door_sprite : AnimatedSprite = $DoorSprite

onready var collision_width : float = $Area2D/CollisionShape2D.shape.extents.x

export var open_audio : AudioStream
export var close_audio : AudioStream

const DOOR_BOTTOM_DISTANCE := 35

export (float) var slide_to_center_length := 0.5
export (float) var entering_door_length := 0.75 
export (float) var exiting_door_length := 0.75
var reset_read_timer := 1.0

export var is_idle := true
var entering = false
# amount we currently have of desired collectible
var current_amount := 0

var stored_character : Character

#func _ready():
#	tween.connect("tween_all_completed", self, "_tween_all_completed")

func _physics_process(_delta : float) -> void:
	if is_idle:
		#the area2d is set to only collide with characters, so we can (hopefullY) safely assume if there 
		#is a collision it's with a character
		
		# you're not able to enter a door if you're in the air, aren't controllable,
		# have dive collision enabled, or are pressing a movement direction (helps with the Legacy control preset)
		for body in area2d.get_overlapping_bodies():
			if (body is Character and global_rotation == 0 and body.is_grounded()
			and body.get_input(Character.input_names.interact, false)
			and !body.get_input(Character.input_names.left, false) and !body.get_input(Character.input_names.right, false)
			and body.controllable and body.ground_collision_dive.disabled
			and get_parent().enabled
			# Rainbow Mario can't enter doors
			and !(is_instance_valid(body.powerup) and body.powerup.name == "RainbowPowerup")):
				start_door_enter_animation(body)

func start_door_locked_animation(_character : Character) -> void:
	pass # to be implemented

func start_door_enter_animation(character : Character) -> void:
	stored_character = character
	
	is_idle = false
	entering = true
	
	character.set_dive_collision(false)
	character.toggle_movement(false)
	character.velocity = Vector2.ZERO
	character.sprite.rotation = 0
	character.set_collision_layer_bit(1, false) # disable collisions w/ most things
	character.set_inter_player_collision(false)
	
	character.sprite.animation = "enterDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	
	
	
	var slide_length : float = slide_to_center_length
	
	#calculate the amount of time it should take based on the players distance from the center
	var distance_from_center_normalized : float = abs((character.position.x - global_position.x)) / collision_width 
	distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
	slide_length = slide_to_center_length * distance_from_center_normalized 
	var can_enter = true
	# yucky code to stop character from entering if they dont have enough
	if get_parent().collectible == "coin":
		if Singleton.CurrentLevelData.level_data.vars.coins_collected < get_parent().required_amount:
			can_enter = false
	else:
		var collected = 0
		#yuck
		for col in get_parent().collectible_dictionary:
			if get_parent().collectible_dictionary[col]:
				collected += 1
		if collected < get_parent().required_amount:
			can_enter = false
			
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character, "position:x", null, global_position.x, slide_length)
	# warning-ignore: return_value_discarded
	if can_enter:
		animate_door("open")
		tween.interpolate_callback(character.anim_player, slide_length + (door_sprite.frames.get_frame_count("open") * 2 * fps_util.PHYSICS_DELTA), "play", "enter_door")
		character.anim_player.connect("animation_finished", self, "character_animation_finished", [character], CONNECT_ONESHOT)
	else:
		#copied this from the sign code
		character.sprite.animation = "enterDoor" + ("Right" if character.facing_direction == 1 else "Left")
		character.sprite.playing = true
		tween.interpolate_callback(self, slide_length / 2.75, "open_menu_ui", character)
	# warning-ignore: return_value_discarded
	tween.start()
	
	# when mario finishes entering the door, trigger a function (one shot)
	# warning-ignore: return_value_discarded
	
	
func open_menu_ui(character):
	get_tree().get_current_scene().get_node("UI/SignText").open(get_parent().text, self, character)
	
func character_animation_finished(_animation : String, character : Character) -> void:
	# this is so the door closes after mario enters
	animate_door("close")
	emit_signal("start_door_logic", character, entering)
	
func animate_door(animation : String = "close") -> void:
	# this function just plays the door animation, so code doesn't have to repeat
	door_sprite.animation = animation
	door_sprite.playing = true
	audio_player.stream = open_audio if animation == "open" else close_audio
	audio_player.play()

func start_door_exit_animation(character : Character, tp_mode : bool) -> void:
	# just plays a few animations
	stored_character = character
	
	is_idle = false
	entering = false
	
	character.toggle_movement(false)
	
	if !tp_mode:
		emit_signal("exit", character, entering)
	
	animate_door("open")
	character.anim_player.play("exit_door")
	# when mario finishes exiting, run a function (one shot)
	# warning-ignore: return_value_discarded

	character.anim_player.connect("animation_finished", self, "door_exit_anim_finished", [character], CONNECT_ONESHOT)

	# warning-ignore: return_value_discarded
	tween.start()

func door_exit_anim_finished(_animation : String, character : Character) -> void:
	# closes the door and gives back control to mario
	Singleton.CurrentLevelData.level_data.vars.transition_data = []
	is_idle = true
	entering = false
	character.velocity = Vector2.ZERO
	character.toggle_movement(true)
	# undo collision changes 
	character.set_collision_layer_bit(1, true)
	character.set_inter_player_collision(true) 
	
	character.sprite.animation = "exitDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	animate_door("close")

func _tween_all_completed() -> void:
	emit_signal("door_animation_finished", stored_character)
	stored_character = null
	
func restore_control():
	stored_character.velocity = Vector2.ZERO
	stored_character.toggle_movement(true)
	stored_character.invulnerable = false 
	stored_character.controllable = true
	stored_character.movable = true
	
	stored_character.get_state_node("JumpState").jump_buffer = 0 # prevent character from jumping right after closing menu
	stored_character.inputs[Character.input_names.jump][1] = false
	stored_character.set_collision_layer_bit(1, true)
	stored_character.set_inter_player_collision(true) 
	
	stored_character.sprite.animation = "exitDoor" + ("Right" if stored_character.facing_direction == 1 else "Left")
	stored_character.sprite.playing = true
	tween.stop_all()
	tween.remove_all()
	tween.interpolate_property(self, "is_idle", false, true, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
