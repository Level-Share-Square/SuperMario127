extends TeleportObject

onready var icon = $DoorEnterLogic/Icon
onready var door = $DoorEnterLogic/Door
onready var door_enter_logic = $DoorEnterLogic

export(Array, Texture) var palette_textures
export(Array, SpriteFrames) var palette_frames

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

var possible_coll = ["shine", "star coin", "coin"]
var coll

const OPEN_DOOR_WAIT = 0.45

func _set_properties() -> void:
	savable_properties = ["area_id", "destination_tag", "teleportation_mode", "collectible", "required_amount"]
	editable_properties = ["area_id", "destination_tag", "teleportation_mode", "collectible", "required_amount"]
	
func _set_property_values() -> void:

	set_property("area_id", area_id)
	set_property("destination_tag", destination_tag)
	set_property("teleportation_mode", teleportation_mode, true, "Teleport Mode")
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("collectible", collectible)
	set_property("required_amount", required_amount)
	set_property("force_fadeout", force_fadeout)


func _init():
	teleportation_mode = false
	object_type = "door"

func _ready() -> void:
	prev_coll = collectible
	coll = collectible
	.ready() #calls parent class "TeleportObject"i
	if is_preview:
		z_index = 0
		icon.z_index = 0
		door.z_index = 0
	if possible_coll.has(collectible):
		icon.animation = palette_dict[palette] + "_" + collectible + "_open"
	else:
		icon.animation = "null"
	door.animation = palette_dict[palette] + "_open"
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
		"shines":
			collectible_dictionary = current_level_info.collected_shines
		"star coin":
			collectible_dictionary = current_level_info.collected_star_coins
		"coin":
			pass
		_:
			collectible_dictionary = current_level_info.collected_shines
			
		
	if(required_amount == 1):
		text = "Sorry! You need " + String(required_amount) + " " + collectible + " to open this door!"
	else:
		text = "Sorry! You need " + String(required_amount) + " " + collectible + "s to open this door!"
	

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
			icon.animation = palette_dict[palette] + "_" + collectible + "_open"
		else:
			icon.animation = "null"
	coll = collectible
	if "\n" in destination_tag:
		destination_tag = destination_tag.replace("\n", "")
