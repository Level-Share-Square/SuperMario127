extends Teleporter


onready var area2d : Area2D = $Area2D
onready var tween : Tween = $Tween
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var audio_fast : AudioStreamPlayer = $AudioFast

onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var sprite = $Sprite
onready var sprite2 = $Sprite/Sprite2

onready var collision_width : float = $Area2D/CollisionShape2D.shape.extents.x

const PIPE_BOTTOM_DISTANCE := 0.0
const PIPE_EXIT_DISTANCE := 47.0

export (float) var slide_to_center_length := 0.4
export (float) var slide_to_center_fast_length := 0.05
export (float) var entering_pipe_length := 1.0
export (float) var entering_pipe_fast_length := 0.2
export (float) var exiting_pipe_length := 1.0
var stored_character : Character

export var normal_texture : Texture
export var recolorable_texture : Texture 
var color := Color(0, 1, 0)


# overriding cos pipes can be recolored
### PROPERTIES
#func _set_properties() -> void:
#	savable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path", "color"]
#	editable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path", "color"]


func _register_properties() -> void:
	._register_properties()
	register_property(9, "color", color)


func _on_property_changed(key, value):
	if key == "color":
		if color == Color(0, 1, 0):
			sprite.texture = normal_texture
			sprite2.visible = false
			sprite.self_modulate = Color(1, 1, 1)
		else:
			sprite.texture = recolorable_texture
			sprite2.visible = true
			sprite.self_modulate = value
			var bright_color = value
			bright_color.s /= 1.5
			bright_color.v *= 1.15
			sprite2.self_modulate = bright_color


### ANIMATION
func start_entrance_animation(character: Character, is_gp: bool = false) -> void:
	.start_entrance_animation(character)
	
	character.global_position.y = global_position.y - 48
	
	if not is_gp:
		character.sprite.animation = "pipe" + ("Right" if character.facing_direction == 1 else "Left")
		character.sprite.playing = true

		var slide_length : float = slide_to_center_length

		#calculate the amount of time it should take based on the players distance from the center
		var distance_from_center_normalized : float = abs((character.position.x - global_position.x)) / collision_width 
		distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
		slide_length = slide_to_center_length * distance_from_center_normalized

		# warning-ignore: return_value_discarded
		tween.interpolate_property(character, "position:x", null, global_position.x, slide_length)
		# warning-ignore: return_value_discarded
		tween.interpolate_property(character, "position:y", null, global_position.y + PIPE_BOTTOM_DISTANCE, \
				entering_pipe_length, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, slide_length)
		# warning-ignore: return_value_discarded
		tween.interpolate_callback(audio_player, slide_length, "play")
		# warning-ignore: return_value_discarded
		tween.interpolate_callback(self, slide_length + entering_pipe_length, "emit_signal", "entrance_completed")

		# warning-ignore: return_value_discarded
		tween.start()
	
	else:
		if character.state != null && character.state.name == "GroundPoundState":   # ====================================================
			character.state = null													# | This is for local teleportation. If this wasn't  |
																					# | here, you would exit while still ground pounding |
																					# | if you entered from a pipe with a ground pound.  |
																					# ====================================================

		character.sprite.animation = "groundPound" + ("Right" if character.facing_direction == 1 else "Left")
		character.sprite.playing = true

		var slide_length : float = slide_to_center_fast_length

		# warning-ignore: return_value_discarded
		tween.interpolate_property(character, "position:x", null, global_position.x - character.facing_direction, slide_length)
		# warning-ignore: return_value_discarded
		tween.interpolate_property(character, "position:y", null, global_position.y + PIPE_BOTTOM_DISTANCE, entering_pipe_fast_length)
		# warning-ignore: return_value_discarded
		tween.interpolate_callback(self, entering_pipe_fast_length, "emit_signal", "entrance_completed")
		
		# warning-ignore: return_value_discarded
		tween.start()
		audio_fast.play()


func start_exit_animation(character: Character) -> void:
	.start_exit_animation(character)
	
	character.sprite.animation = "pipeRight"
	character.sprite.playing = true
	character.sprite.frame = 2
	
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character, "position:y", global_position.y + PIPE_BOTTOM_DISTANCE, \
			global_position.y - PIPE_EXIT_DISTANCE, exiting_pipe_length)
	#this next line is kinda janky but hopefully it should set the animation after the above property
	#finishes animating, basically it has duration 0 and a delay the same length as the duration of the above line
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character.sprite, "animation", null, "pipeExit" + \
			("Right" if character.facing_direction == 1 else "Left"), 0.0, 0, 2, exiting_pipe_length)
	
	# warning-ignore: return_value_discarded
	tween.interpolate_callback(audio_player, 0.25, "play")

	# when mario finishes exiting, run a function (one shot)
	# warning-ignore: return_value_discarded
	tween.connect("tween_all_completed", self, "emit_signal", ["exit_completed"], CONNECT_ONESHOT)
	
	# warning-ignore: return_value_discarded
	tween.start()
	
	reset_sprite(character)


func reset_sprite(character : Character): #This is here in case Mario came from a door to a pipe
	character.show()
	character.z_index = -9
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
func _physics_process(_delta: float) -> void:
	if not is_enabled_and_on_ground(): return
	if global_rotation != 0: return
	if not is_instance_valid(stored_character): return
	if not stored_character.is_grounded(): return
	if not stored_character.controllable: return
	if is_rainbow(stored_character): return
	
	var is_ground_pound = (
		is_instance_valid(stored_character.state) and 
		(stored_character.state.name == "GroundPoundState" or stored_character.state.name == "GroundPoundEndState")
	)
	if (stored_character.get_input(Character.input_names.crouch, true) or is_ground_pound and stored_character.get_input(Character.input_names.gp, false)) and target_area != -1:
		start_entrance_animation(stored_character, is_ground_pound)


### MISC
func _ready():
	._ready()
	
	_on_property_changed("color", color)
	connect("property_changed", self, "_on_property_changed")
	get_node("StaticBody2D/CollisionShape2D").disabled = !is_enabled_and_on_ground()

func is_rainbow(body) -> bool:
	return body.powerup != null and body.powerup.id == "Rainbow"
