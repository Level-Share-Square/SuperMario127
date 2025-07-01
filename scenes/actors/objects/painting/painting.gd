extends Teleporter


onready var tween: Tween = $Tween
onready var exit_sound = $ExitSound
onready var collision_width: float = $Area2D/CollisionShape2D.shape.extents.x
onready var bg: TextureRect = $"%BG"
onready var custom_image: TextureRect = $"%CustomImage"

export(float) var slide_to_center_length := 0.5
export var placeholder_texture: StreamTexture

var busy: bool = false
var stored_character: Character


### ANIMATION
func start_entrance_animation(character: Character) -> void:
	.start_entrance_animation(character)
	
	busy = true
	character.sound_player.play_jump_sound()
	character.sprite.animation = "enterPainting"
	character.sprite.playing = true

	var slide_length : float = slide_to_center_length
	
	#calculate the amount of time it should take based on the players distance from the center
	var distance_from_center_normalized : float = abs((character.position.x - global_position.x)) / collision_width 
	distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
	slide_length = slide_to_center_length * distance_from_center_normalized
	
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character, "position:y", null, global_position.y - 12, 0.6, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character.sprite, "scale", null, Vector2(0.95, 0.95), 0.6)
	# warning-ignore: return_value_discarded
	tween.start()
	
	yield(get_tree().create_timer(0.6), "timeout")
	
	bg.material.set_shader_param("offset", (character.position.x - position.x) / (bg.rect_size.x/2))
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character, "position:y", null, global_position.y - 4, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character.sprite, "scale", null, Vector2(0.8, 0.8), 0.2)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character.sprite, "modulate", null, Color(5, 5, 5, 0), 0.2)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(bg.material, "shader_param/height", null, 0.07, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN, 0.1)
	# warning-ignore: return_value_discarded
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	Singleton.SceneTransitions.play_transition_audio()
	if teleport_mode == TeleportMode.Level and Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		# warning-ignore: return_value_discarded
		tween.interpolate_property(character.camera, "zoom", null, Vector2(0.75, 0.75), 1.25, Tween.TRANS_LINEAR)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(bg.material, "shader_param/height", null, 0, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(self, "busy", null, false, 0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.5)
	# warning-ignore: return_value_discarded
	tween.start()
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	# when mario finishes entering the door, trigger a function (one shot)
	# warning-ignore: return_value_discarded
	emit_signal("entrance_completed")


func start_exit_animation(character: Character) -> void:
	.start_exit_animation(character)
	
	busy = true
	character.visible = false
	character.sprite.scale = Vector2(0.8, 0.8)
	character.sprite.modulate = Color(5, 5, 5, 0)
	
	bg.material.set_shader_param("offset", 0)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(bg.material, "shader_param/height", 0, 0.1, 0.25, Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore: return_value_discarded
	tween.start()
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character.sprite, "scale", Vector2(0.8, 0.8), Vector2.ONE, 0.2)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(character.sprite, "modulate", Color(5, 5, 5, 0), Color.white, 0.2)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(bg.material, "shader_param/height", null, 0, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# warning-ignore: return_value_discarded
	tween.interpolate_property(self, "busy", null, false, 0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	# warning-ignore: return_value_discarded
	tween.start()
	
	emit_signal("exit_completed")
	
	character.set_state_by_name("ExitPaintingState", 0)
	character.show()
	exit_sound.play()


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
	
	bg.material = bg.material.duplicate()
	custom_image.material = bg.material
	bg.material.set_shader_param("height", 0)
	
	var image = bg.texture.get_data()
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image, 41)
	bg.texture = image_texture
	
	if is_preview:
		z_index = 0

	if scale.x < 1:
		scale.x = abs(scale.x)
	
	painting_resized()
	_on_property_changed("teleport_mode", teleport_mode)
	connect("property_changed", self, "_on_property_changed")


func _on_property_changed(key, value):
	if key == "teleport_mode" or key == "level_path":
		if teleport_mode == TeleportMode.Level: 
			if Singleton.CurrentLevelData.is_campaign:
				var working_folder: String = Singleton.CurrentLevelData.working_folder
				var thumb_path: String = level_list_util.get_level_thumbnail_path(level_path, working_folder)
				if level_list_util.file_exists(thumb_path):
					custom_image.texture = level_list_util.get_image_from_path(thumb_path)
					custom_image.texture = custom_image.texture.duplicate()
					custom_image.texture.flags = 41
					custom_image.visible = true
				else:
					custom_image.texture = placeholder_texture
		else:
			custom_image.visible = false


func painting_resized():
	bg.material.set_shader_param("ratio", Vector2(bg.rect_size.x / bg.rect_size.y, 1))
