extends TeleportObject


const SINGLE_VOLUME: float = -8.0
const DOUBLE_VOLUME: float = 6.0

onready var collision_shape: CollisionShape2D = $DoorEnterLogic/Area2D/CollisionShape2D
onready var icon: AnimatedSprite = $DoorEnterLogic/Icon
onready var door: AnimatedSprite = $DoorEnterLogic/Door
onready var audio_player: AudioStreamPlayer = $DoorEnterLogic/AudioStreamPlayer
onready var door_enter_logic: Node2D = $DoorEnterLogic

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

var stored_character : Character
var current_level_info : LevelInfo
var required_amount := 1
var collectible := "shine"
var collectible_dictionary : Dictionary
var text := ""
var prev_coll
var insufficient_text: String = "Sorry! You need {num} {col} to open this door!"
var is_single: bool = false

var possible_coll = ["shine", "star coin", "coin", "star bit"]
var coll

const OPEN_DOOR_WAIT = 0.45

func _set_properties() -> void:
	savable_properties = ["area_id", "destination_tag", "teleportation_mode", "collectible", "required_amount", "insufficient_text", "is_single"]
	editable_properties = ["area_id", "destination_tag", "teleportation_mode", "collectible", "required_amount", "insufficient_text"]
	
func _set_property_values() -> void:

	set_property("area_id", area_id)
	set_property("destination_tag", destination_tag)
	set_property("teleportation_mode", teleportation_mode, true, "Teleport Mode")
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("collectible", collectible)
	set_property_menu("collectible", ["option_string", possible_coll, 0, ["Shines", "Star Coins", "Coins", "Star Bits"]])
	set_property("required_amount", required_amount)
	set_property("force_fadeout", force_fadeout)
	set_property("insufficient_text", insufficient_text)
	set_property("is_single", is_single)


func _init():
	teleportation_mode = false
	object_type = "door"

func _ready() -> void:
	# weird system but whateverrr :p
	# also reusing the paratroopa one cuz idk dont feel like making new script
	var scene = get_tree().current_scene
	if scene.mode == 1 and scene.placed_item_property == "Para":
		set_property("is_single", true)
	
	# set up single vs double doors
	door.frames = single_door_frames if is_single else double_door_frames
	icon.frames = single_icon_frames if is_single else double_icon_frames
	collision_shape.shape = single_area_shape if is_single else double_area_shape
	
	door_enter_logic.open_audio = single_open_audio if is_single else double_open_audio
	door_enter_logic.close_audio = single_close_audio if is_single else double_close_audio
	audio_player.volume_db = SINGLE_VOLUME if is_single else DOUBLE_VOLUME
	
	# everything else :D
	prev_coll = collectible
	coll = collectible
	.ready() #calls parent class "TeleportObject"i
	if is_preview:
		z_index = 0
		icon.z_index = 0
		door.z_index = 0
	if possible_coll.has(collectible):
		icon.animation = palette_dict[palette] + "_" + collectible
	else:
		icon.animation = "null"
	door.animation = palette_dict[palette]
	if scale.x < 1:
		scale.x = abs(scale.x)
		icon.flip_h = true
		door.flip_h = true
	
	var append_tag
	if destination_tag != "default_teleporter" || destination_tag != null:
		append_tag = destination_tag.to_lower()
	Singleton.CurrentLevelData.level_data.vars.teleporters.append([append_tag, self])
	
	current_level_info = Singleton.CurrentLevelData.level_info
	match(collectible):
		"shine":
			collectible_dictionary = current_level_info.collected_shines
		"star coin":
			collectible_dictionary = current_level_info.collected_star_coins
		"coin":
			pass
		"star bit":
			pass
		_:
			collectible_dictionary = current_level_info.collected_shines
	
	var collectible_text: String = collectible
	if required_amount != 1: collectible_text += "s"
	text = insufficient_text.format({
		"num": required_amount,
		"col": collectible_text
	})
	

func connect_local_members():
	door_enter_logic.connect("start_door_logic", self, "_start_local_transition")
	door_enter_logic.connect("exit", self, "_start_local_transition")

func connect_remote_members():
	door_enter_logic.connect("start_door_logic", self, "change_areas")

func start_exit_anim(character):
	door_enter_logic.start_door_exit_animation(character, teleportation_mode)

func exit_local_teleport():
	if tp_pair != self:
		door_enter_logic.is_idle = true

func exit_remote_teleport():
	Singleton.CurrentLevelData.level_data.vars.transition_data = []
	door_enter_logic.is_idle = true

func _process(delta):
	prev_coll = collectible
	if prev_coll != coll:
		if possible_coll.has(collectible):
			icon.animation = palette_dict[palette] + "_" + collectible
		else:
			icon.animation = "null"
	coll = collectible
	if "\n" in destination_tag:
		destination_tag = destination_tag.replace("\n", "")
