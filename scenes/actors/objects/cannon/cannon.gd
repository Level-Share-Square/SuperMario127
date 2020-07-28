# TODO:
# sounds [Partially complete]
# player bool that disables all but input polling 
# player into dive state after cannon shot [DONE]
# general polish (maybe some particles?)
# change fire key to fludd [DONE]
# change all the nodes to use variables instead [DONE]
extends GameObject

onready var pipe_enter_logic = $PipeEnterLogic
onready var cannon_exit_position = $CannonMoveable/SpriteBody/CannonExitPosition
onready var collision_shape = $EntranceCollision/CollisionShape2D
onready var sprite_body = $CannonMoveable/SpriteBody
onready var sprite_fuse = $CannonMoveable/SpriteBody/SpriteFuse
onready var animation_player = $AnimationPlayer
onready var tween = $Tween 
onready var audio_player = $AudioStreamPlayer
onready var particles = $CannonMoveable/SpriteBody/Particles2D

var stored_character

const ROTATION_RETURN_TIME = 0.5

export (float) var launch_power = 1200
export (float) var min_rotation = 0
export (float) var max_rotation = 90
	
onready var cannon_fire_noise = preload("res://scenes/actors/objects/cannon/nsmbwiiBobombCannon.wav")

func _ready():
	set_physics_process(false)
	# warning-ignore:return_value_discarded
	pipe_enter_logic.connect("pipe_animation_finished", self, "_start_cannon_animation")

#disabled by default until process is enabled, so this can assume the cannon is already in an active state
func _physics_process(delta):
	#if the jump button is pressed, fire the cannon
	if stored_character.get_input(Character.input_names.fludd, true):
		set_physics_process(false)

		#return the player control and such to normal 
		stored_character.invulnerable = false
		stored_character.controllable = true
		stored_character.movable = true

		#set the player so they will fire out of the cannon properly with velocity and such
		stored_character.position = cannon_exit_position.global_position
		stored_character.velocity = Vector2.UP.rotated(sprite_body.rotation) * launch_power
		stored_character.facing_direction = 1 #this line will need to be changed for when the cannon being able to face left is implemented
		stored_character.set_state(stored_character.get_node("States/DiveState"), delta)

		#play cannon fire sound
		audio_player.stream = cannon_fire_noise
		audio_player.volume_db = 0 #volume is changed by the animation player so this is necessary to keep it audibles
		audio_player.play()

		#cannon fire particles 
		particles.emitting = true

		#return cannon to pointing straight up so it can retract
		tween.interpolate_property(sprite_body, "rotation", null, 0, ROTATION_RETURN_TIME)	
		tween.start()

	#booleans when converting to integer are 0 or 1, so doing right - left means when right is pressed, it'll be 1, when left is pressed it'll be -1, and when both/neither are pressed it'll be 0
	var horizontal_input = int(stored_character.get_input(Character.input_names.right, false)) - int(stored_character.get_input(Character.input_names.left, false))

	if horizontal_input != 0:
		sprite_body.rotation += horizontal_input * delta
		sprite_body.rotation = clamp(sprite_body.rotation, deg2rad(min_rotation), deg2rad(max_rotation))

func _start_cannon_animation(character):
	stored_character = character 

	animation_player.play("cannon_startup")

	collision_shape.disabled = true

func _on_animation_finished(anim_name):
	if anim_name == "cannon_startup":
		stored_character.controllable = true
		sprite_fuse.visible = true
		set_physics_process(true)
	else:
		collision_shape.disabled = false
		pipe_enter_logic.is_idle = true

#the tween is used for returning the cannons rotation to 0 so it can retract while pointing straight up
func _on_tween_all_completed():
	animation_player.play("cannon_retract")
	sprite_fuse.visible = false
