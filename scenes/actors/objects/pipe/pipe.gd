extends TeleportObject

onready var pipe_enter_logic = $PipeEnterLogic
onready var sprite = $Sprite
onready var sprite2 = $Sprite/Sprite2

export var normal_texture : Texture
export var recolorable_texture : Texture 
var color := Color(0, 1, 0)

func _set_properties():
	savable_properties = ["area_id", "destination_tag", "color", "teleportation_mode"]
	editable_properties = ["area_id", "destination_tag", "color", "teleportation_mode"]
	
func _set_property_values():
	set_property("area_id", area_id, true, "Area Destination")
	set_property("destination_tag", destination_tag, true)
	set_property("color", color, true)
	set_property("teleportation_mode", teleportation_mode, true, "Teleport Mode")
	set_bool_alias("teleportation_mode", "Remote", "Local")


func _ready():
	object_type = "pipe"
	.ready() #Calls parent class "TeleportObject"

	if rotation != 0 and enabled: #TODO: Vertical & Lateral pipes
		enabled = false
	if rotation == 0:
		Singleton.CurrentLevelData.level_data.vars.teleporters.append([destination_tag.to_lower(), self])
	if color == Color(0, 1, 0):
		sprite.texture = normal_texture
		sprite2.visible = false
		sprite.self_modulate = Color(1, 1, 1)
	else:
		sprite.texture = recolorable_texture
		sprite2.visible = true
		sprite.self_modulate = color
		var bright_color = color
		bright_color.s /= 1.5
		bright_color.v *= 1.15
		sprite2.self_modulate = bright_color


func connect_local_members():
	pipe_enter_logic.connect("pipe_animation_finished", self, "_start_local_transition")
	pipe_enter_logic.connect("exit", self, "_start_local_transition")

func connect_remote_members():
	pipe_enter_logic.connect("pipe_animation_finished", self, "change_areas")
	

func exit_local_teleport():
	pipe_enter_logic.is_idle = true
	

func exit_remote_teleport():
	pipe_enter_logic.is_idle = true

func start_exit_anim(character):
	pipe_enter_logic.start_pipe_exit_animation(character, teleportation_mode)

func get_bottom_distance():
	return pipe_enter_logic.PIPE_BOTTOM_DISTANCE - 30
