extends GameObject

onready var sprite = $DoorEnterLogic/DoorSprite
onready var door_enter_logic = $DoorEnterLogic
onready var tween = $DoorEnterLogic/Tween
var stored_character : Character

const OPEN_DOOR_WAIT = 0.45
## For older levels only
var tag : String = "none"
var teleport_to_tag : String = "none"
###
var door_tag : String = "default"

func _set_properties() -> void:
	savable_properties = ["tag", "teleport_to_tag", "door_tag"]
	editable_properties = ["door_tag"]
	
func _set_property_values() -> void:
	set_property("tag", tag)
	set_property("teleport_to_tag", teleport_to_tag)
	set_property("door_tag", door_tag)

func _ready() -> void:
	if mode == 1:
		tag = "none"
		teleport_to_tag = "none"
		_set_property_values()
		
	if is_preview:
		z_index = 0
		sprite.z_index = 0

	if scale.x < 1:
		scale.x = abs(scale.x)
		sprite.flip_h = true
	var append_tag = door_tag.to_lower()
	if tag != "none":
		append_tag = tag.to_lower()
	Singleton.CurrentLevelData.level_data.vars.doors.append([append_tag, self])
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
	Singleton.SceneTransitions.canvas_mask.position = get_character_screen_position(character)
	# this starts an inner scene transition, then connects a function (one shot) to start as it finishes
	Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, -1, -1, false, false)
	# warning-ignore: return_value_discarded
	Singleton.SceneTransitions.connect("transition_finished", self, "_start_teleport", [character], CONNECT_ONESHOT)

func _start_teleport(character : Character) -> void:
	var teleport_door = self
	
	# looks for all doors in the level, and if the tag matches, it sets the door to teleport to, then breaks the loop
	for found_door in Singleton.CurrentLevelData.level_data.vars.doors:
		var condition = found_door[0] == door_tag.to_lower() and found_door[1] != self
		if teleport_to_tag != "none":
			condition = found_door[0] == teleport_to_tag.to_lower()
		if condition:
			teleport_door = found_door[1]
			break
	
	# this changes mario's position, then waits a bit before starting the door exit animation
	character.position = teleport_door.global_position
	character.camera.position = character.position
	character.camera.skip_to_player = true
	tween.interpolate_callback(teleport_door.door_enter_logic, OPEN_DOOR_WAIT, "start_door_exit_animation", character)
	tween.start()
	
	# sets the transition center to Mario's position
	Singleton.SceneTransitions.canvas_mask.position = get_character_screen_position(character)
	# start outer transition
	Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, -1, -1, false, false)
	
	if teleport_door != self:
		door_enter_logic.is_idle = true
