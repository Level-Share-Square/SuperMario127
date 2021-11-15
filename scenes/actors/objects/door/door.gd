extends TeleportObject

onready var sprite = $DoorEnterLogic/DoorSprite
onready var door_enter_logic = $DoorEnterLogic

var stored_character : Character

const OPEN_DOOR_WAIT = 0.45

func _set_properties() -> void:
	savable_properties = ["tag", "teleport_to_tag", "door_tag", "area_id", "destination_tag", "teleportation_mode"]
	editable_properties = ["area_id", "destination_tag", "teleportation_mode"]
	
func _set_property_values() -> void:

	set_property("area_id", area_id)
	set_property("destination_tag", destination_tag)
	set_property("tag", tag)
	set_property("teleport_to_tag", teleport_to_tag)
	set_property("teleportation_mode", teleportation_mode, true, "Teleport Mode")
	set_bool_alias("teleportation_mode", "Remote", "Local")


func _init():
	teleportation_mode = false
	object_type = "door"

func _ready() -> void:
	.ready() #calls parent class "TeleportObject"
	if mode == 0: convert_to_0_7_1()
	elif mode == 1:
		convert_to_0_7_1()
		door_tag = "none"
		tag = "none"
		teleport_to_tag = "none"
		_set_property_values()
	if is_preview:
		z_index = 0
		sprite.z_index = 0

	if scale.x < 1:
		scale.x = abs(scale.x)
		sprite.flip_h = true
	var append_tag 
	if teleport_to_tag != "none" || teleport_to_tag != null:
		append_tag = teleport_to_tag.to_lower()
	if door_tag != "none" || door_tag != null:
		append_tag = door_tag.to_lower()
	if destination_tag != "default_teleporter" || destination_tag != null:
		append_tag = destination_tag.to_lower()
	Singleton.CurrentLevelData.level_data.vars.teleporters.append([append_tag, self])


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
	door_enter_logic.is_idle = true

func convert_to_0_7_1():
	var true_tag = destination_tag
	if teleport_to_tag != "none":
		true_tag = teleport_to_tag
	if door_tag != "none":
		true_tag = door_tag
	destination_tag = true_tag
