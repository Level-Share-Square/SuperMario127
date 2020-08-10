extends GameObject

onready var sprite = $DoorEnterLogic/DoorSprite
onready var door_enter_logic = $DoorEnterLogic
onready var tween = $DoorEnterLogic/Tween
var stored_character : Character

const OPEN_DOOR_WAIT = 0.45
var tag : String = "default"
var teleport_to_tag : String = "default"

func _set_properties() -> void:
	savable_properties = ["tag", "teleport_to_tag"]
	editable_properties = ["tag", "teleport_to_tag"]
	
func _set_property_values() -> void:
	set_property("tag", tag)
	set_property("teleport_to_tag", teleport_to_tag)

func _ready() -> void:
	CurrentLevelData.level_data.vars.doors.append([tag.to_lower(), self])
	door_enter_logic.connect("start_door_logic", self, "_start_transition")

func get_character_screen_position(character : Character) -> Vector2:
	# Find the camera pos, clamped to its limits
	var camera_pos = character.camera.position
	camera_pos.x = clamp(camera_pos.x, character.camera.limit_left + 384, character.camera.limit_right - 216)
	camera_pos.y = clamp(camera_pos.y, character.camera.limit_top + 384, character.camera.limit_bottom - 216)
	# Return relative screen position
	return character.position - camera_pos + Vector2(384, 216)

func _start_transition(character : Character) -> void:
	# sets the transition center to Mario's position
	scene_transitions.canvas_mask.position = get_character_screen_position(character)
	# this starts an inner scene transition, then connects a function (one shot) to start as it finishes
	scene_transitions.do_transition_animation(scene_transitions.cutout_circle, scene_transitions.DEFAULT_TRANSITION_TIME, scene_transitions.TRANSITION_SCALE_UNCOVER, scene_transitions.TRANSITION_SCALE_COVERED, -1, -1, false)
	# warning-ignore: return_value_discarded
	scene_transitions.connect("transition_finished", self, "_start_teleport", [character], CONNECT_ONESHOT)

func _start_teleport(character : Character) -> void:
	var teleport_door = self
	
	# looks for all doors in the level, and if the tag matches, it sets the door to teleport to, then breaks the loop
	for found_door in CurrentLevelData.level_data.vars.doors:
		if found_door[0] == teleport_to_tag.to_lower():
			teleport_door = found_door[1]
			break
	
	# this changes mario's position, then waits a bit before starting the door exit animation
	# it also tries to stop the camera from smoothing to the position, but that didn't work, for some reason
	character.position = teleport_door.global_position
	character.camera.position = character.position
	character.camera.smoothing_enabled = false # Temporarily disable smoothing to let it snap to Mario
	tween.interpolate_callback(teleport_door.door_enter_logic, OPEN_DOOR_WAIT, "start_door_exit_animation", character)
	tween.start()
	
	# sets the transition center to Mario's position
	scene_transitions.canvas_mask.position = get_character_screen_position(character)
	# start outer transition
	scene_transitions.do_transition_animation(scene_transitions.cutout_circle, scene_transitions.DEFAULT_TRANSITION_TIME, scene_transitions.TRANSITION_SCALE_COVERED, scene_transitions.TRANSITION_SCALE_UNCOVER, -1, -1, false)
	
	if teleport_door != self:
		door_enter_logic.is_idle = true
