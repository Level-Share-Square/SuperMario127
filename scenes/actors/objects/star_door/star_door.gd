extends DoorTeleport


const SINGLE_VOLUME: float = -8.0
const DOUBLE_VOLUME: float = 6.0

onready var icon_sprite = $IconSprite
onready var collision_shape = $Area2D/CollisionShape2D
onready var door_background = $ZIndex/DoorBackground

export var double_door_frames: SpriteFrames
export var single_door_frames: SpriteFrames

export var double_icon_frames: SpriteFrames
export var single_icon_frames: SpriteFrames

export var double_area_shape: Shape2D
export var single_area_shape: Shape2D

export var double_open_audio: AudioStream
export var double_close_audio: AudioStream

export var single_open_audio: AudioStream
export var single_close_audio: AudioStream

var palette_dict = {
	0: "wood",
	1: "metal",
	2: "spooky",
	3: "rusty",
	4: "plank"
}

var current_level_info : LevelInfo
var required_amount := 1
var collectible := "shine"
var collectible_count: int
var text := ""
var prev_coll
var insufficient_text: String = "Sorry! You need {num} {col} to open this door!"
var is_single: bool = false
var reset_read_timer := 0.0

var possible_coll = ["shine", "star coin", "coin", "star bit", "unknown"]
var coll


# overriding cos star doors have a bunch of unique properties that need accounting for
### PROPERTIES
func _set_properties() -> void:
	savable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path", "collectible", "required_amount", "insufficient_text", "is_single"]
	editable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path", "collectible", "required_amount", "insufficient_text"]


func _set_property_values() -> void:
	set_property("target_area", target_area)
	set_property("tag", tag)
	set_property("teleport_mode", teleport_mode, true)
	set_property_menu("teleport_mode", ["option", 3, 0, ["Location", "Area", "Level"]])
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("max_pan_distance", max_pan_distance)
	set_property("level_path", level_path)

	set_property("collectible", collectible)
	set_property_menu("collectible", ["option_string", possible_coll, 0, ["Shines", "Star Coins", "Coins", "Star Bits", "Empty"]])
	set_property("required_amount", required_amount)
	set_property("insufficient_text", insufficient_text)
	set_property("is_single", is_single)


func _on_property_changed(key, value):
	if key == "collectible":
		prev_coll = collectible
		if prev_coll != coll:
			if collectible != "unknown" and possible_coll.has(collectible):
				icon_sprite.animation = palette_dict[palette] + "_" + collectible
			else:
				icon_sprite.animation = "null"
		coll = collectible


## ANIMATION
func start_entrance_animation(character: Character, open_door: bool = true) -> void:
	stored_character = character
	var can_enter = true
	
	# yucky code to stop character from entering if they dont have enough
	if collectible == "coin":
		if Singleton.CurrentLevelData.level_data.vars.coins_collected < required_amount:
			can_enter = false
	elif collectible == "star bit":
		var star_bits_collected: int = Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][0]
		if star_bits_collected < required_amount:
			can_enter = false
	else:
		if collectible_count < required_amount:
			can_enter = false
	
	if (
		not Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible 
		or Singleton.CurrentLevelData.selected_file == -2
	) and (
		collectible == "shine" or collectible == "star coin"
	):
		can_enter = true
	
	.start_entrance_animation(character, can_enter)
	if not can_enter:
		# calculate the amount of time it should take based on the players distance from the center
		var distance_from_center_normalized: float = abs((character.position.x - global_position.x)) / collision_width 
		distance_from_center_normalized = clamp(distance_from_center_normalized, 0.1, 1)
		var slide_length: float = slide_to_center_length * distance_from_center_normalized
		
		# copied this from the sign code
		character.sprite.animation = "enterDoor" + ("Right" if character.facing_direction == 1 else "Left")
		character.sprite.playing = true
		
		# warning-ignore: return_value_discarded
		tween.interpolate_property(character, "position:x", null, global_position.x, slide_length)
		# warning-ignore: return_value_discarded
		tween.interpolate_callback(self, slide_length / 2.75, "open_menu_ui", character)
		# warning-ignore: return_value_discarded
		tween.start()
		
		disconnect("entrance_completed", self, "begin_warp")


func animate_door(is_backwards: bool) -> void:
	# this function just plays the door animation, so code doesn't have to repeat
	icon_sprite.play(
		palette_dict[palette] + "_" + collectible,
		is_backwards)
	door_sprite.play(
		palette_dict[palette] + "_" + collectible,
		is_backwards)
	audio_player.stream = open_audio if not is_backwards else close_audio
	audio_player.play()


# i probably could do this cleaner but eh
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


### MISC
func _physics_process(delta):
	if reset_read_timer > 0:
		reset_read_timer -= delta
		if reset_read_timer <= 0:
			busy = false

func open_menu_ui(character):
	get_tree().get_current_scene().get_node("%SignText").open(text, self, character)

func _ready() -> void:
	._ready()
	icon_sprite.flip_h = door_sprite.flip_h
	
	# weird system but whateverrr :p
	# also reusing the paratroopa one cuz idk dont feel like making new script
	var scene = get_tree().current_scene
	if scene.mode == 1 and scene.placed_item_property == "Para":
		set_property("is_single", true)
	
	# set up single vs double doors
	door_sprite.set_sprite_frames(single_door_frames if is_single else double_door_frames)
	icon_sprite.set_sprite_frames(single_icon_frames if is_single else double_icon_frames)
	collision_shape.shape = single_area_shape if is_single else double_area_shape
	
	open_audio = single_open_audio if is_single else double_open_audio
	close_audio = single_close_audio if is_single else double_close_audio
	audio_player.volume_db = SINGLE_VOLUME if is_single else DOUBLE_VOLUME
	door_background.rect_position.x = -12 if is_single else -24
	door_background.rect_size.x = 24 if is_single else 48
	
	# everything else :D
	prev_coll = collectible
	coll = collectible
	
	if is_preview:
		z_index = 0
		icon_sprite.z_index = 0
		door_sprite.z_index = 0
	
	if collectible != "unknown" and possible_coll.has(collectible):
		icon_sprite.animation = palette_dict[palette] + "_" + collectible
	else:
		icon_sprite.animation = "null"
	door_sprite.animation = palette_dict[palette]
	
	current_level_info = Singleton.CurrentLevelData.level_info
	match(collectible):
		"shine":
			collectible_count = current_level_info.collected_shines.values().count(true)
		"star coin":
			collectible_count = current_level_info.collected_star_coins.values().count(true)
		"coin":
			pass
		"star bit":
			pass
		_:
			collectible_count = current_level_info.collected_shines.values().count(true)
	
	if collectible == "shine" or "star coin" and Singleton.CurrentLevelData.is_playing_hub_level():
		var total_dict: Dictionary = Singleton.CurrentLevelData.get_meta_collectibles()
		if collectible == "shine":
			collectible_count = total_dict.get("collected_shines", 0)
		elif collectible == "star_coin":
			collectible_count = total_dict.get("collected_star_coins", 0)

	var collectible_text: String = collectible
	if required_amount != 1: collectible_text += "s"
	text = insufficient_text.format({
		"num": required_amount,
		"col": collectible_text
	})
	
	_on_property_changed("collectible", collectible)
	connect("property_changed", self, "_on_property_changed")
