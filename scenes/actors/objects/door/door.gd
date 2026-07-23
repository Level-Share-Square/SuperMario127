class_name DoorTeleport
extends Teleporter


onready var tween : Tween = $Tween
onready var door_sprite : AnimatedSprite = $DoorSprite
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var collision_width : float = $Area2D/CollisionShape2D.shape.extents.x

export var open_audio : AudioStream
export var close_audio : AudioStream

const DOOR_BOTTOM_DISTANCE := 35

export (float) var slide_to_center_length := 0.5
export (float) var entering_door_length := 0.75 
export (float) var exiting_door_length := 0.75

export(Array, Texture) var palette_textures
export(Array, SpriteFrames) var palette_frames

var stored_character : Character
var busy: bool = false


### ANIMATION
func start_entrance_animation(character: Character, open_door: bool = true) -> void:
	.start_entrance_animation(character)
	busy = true
	
	# so that we can call the parent class's entrance anim function without actually opening the door...
	# this is used for star doors, which inherit from regular doors
	if not open_door: return
	
	character.sprite.animation = "enterDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	
	animate_door(false)

	var slide_length : float = slide_to_center_length
	
	#calculate the amount of time it should take based on the players distance from the center
	var distance_from_center_normalized : float = abs((character.position.x - global_position.x)) / collision_width 
	distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
	slide_length = slide_to_center_length * distance_from_center_normalized
	
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character, "position:x", null, global_position.x, slide_length)
	# warning-ignore: return_value_discarded
	tween.interpolate_callback(character.anim_player, slide_length, "play", "enter_door")

	# warning-ignore: return_value_discarded
	tween.start()
	
	# when mario finishes entering the door, trigger a function (one shot)
	# warning-ignore: return_value_discarded
	character.anim_player.connect("animation_finished", self, "entrance_animation_finished", [], CONNECT_ONESHOT)

func entrance_animation_finished(_animation: String) -> void:
	busy = false
	
	animate_door(true)
	emit_signal("entrance_completed")


func start_exit_animation(character: Character) -> void:
	.start_exit_animation(character)
	
	busy = true
	character.toggle_movement(false)
	character.anim_player.play("exit_door")
	animate_door(false)
	
	# when mario finishes exiting, run a function (one shot)
	# warning-ignore: return_value_discarded

	character.anim_player.connect("animation_finished", self, "exit_animation_finished", [character], CONNECT_ONESHOT)
	
	yield(get_tree(), "idle_frame")
	reset_sprite(character)

func exit_animation_finished(_animation: String, character: Character):
	busy = false
	
	character.sprite.animation = "exitDoor" + ("Right" if character.facing_direction == 1 else "Left")
	character.sprite.playing = true
	animate_door(true)
	emit_signal("exit_completed")

func animate_door(is_backwards: bool) -> void:
	# this function just plays the door animation, so code doesn't have to repeat
	door_sprite.play("close" if is_backwards else "open")
	audio_player.stream = close_audio if is_backwards else open_audio
	audio_player.play()


func reset_sprite(character: Character): #This is here in case Mario came from a painting to a door
	character.show()
	character.z_index = -1
	character.sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	character.sprite.scale = Vector2(1.0, 1.0)
	character.sprite.position = Vector2.ZERO



### AREA2D STUFF
func body_entered(body) -> void:
	if not is_instance_valid(stored_character) and body is Character:
		stored_character = body

func body_exited(body) -> void:
	if body == stored_character:
		stored_character = null
### INPUT
func _physics_process(_delta) -> void:
	# you're not able to enter a door if you're in the air, aren't controllable,
	# have dive collision enabled, or are pressing a movement direction (helps with the Legacy control preset)
	# also, rainbow mario can't enter doors
	if not enabled: return
	if global_rotation != 0: return
	if busy: return
	if not is_instance_valid(stored_character): return
	if not stored_character.is_grounded(): return
	if not stored_character.controllable: return
	if not stored_character.ground_collision_dive.disabled: return
	if is_rainbow(stored_character): return
	
	if (
		stored_character.get_input(Character.input_names.interact, false) and 
		not stored_character.get_input(Character.input_names.left, false) and 
		not stored_character.get_input(Character.input_names.right, false)
	):
		start_entrance_animation(stored_character)



### MISC
func is_rainbow(body) -> bool:
	return body.powerup != null and body.powerup.id == "Rainbow"


func _ready() -> void:
	._ready()
	if is_preview:
		z_index = 0
		door_sprite.z_index = 0

	if palette != 0:
		door_sprite.set_sprite_frames(palette_frames[palette - 1])
	if scale.x < 1:
		scale.x = abs(scale.x)
		door_sprite.flip_h = true

func is_middle(check):
	return
