extends GameObject

onready var sprite = $DoorEnterLogic/DoorSprite
onready var door_enter_logic = $DoorEnterLogic
onready var tween = $DoorEnterLogic/Tween
var stored_character : Character

const OPEN_DOOR_WAIT = 0.45

func _ready():
	door_enter_logic.connect("start_door_logic", self, "_start_transition")
	
func _start_transition(character : Character):
	# this starts a scene transition, then connects a function (one shot) to start as it finishes
	scene_transitions.do_transition_animation()
	scene_transitions.connect("transition_finished", self, "_start_teleport", [character], CONNECT_ONESHOT)

func _start_teleport(character : Character):
	# this changes mario's position, then waits a bit before starting the door exit animation
	character.position = self.global_position
	tween.interpolate_callback(door_enter_logic, OPEN_DOOR_WAIT, "start_door_exit_animation", character)
	tween.start()
