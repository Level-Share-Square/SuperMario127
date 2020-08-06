extends GameObject

onready var sprite = $DoorEnterLogic/DoorSprite
onready var door_enter_logic = $DoorEnterLogic
var stored_character : Character

func _ready():
	door_enter_logic.connect("start_door_logic", self, "_start_teleport")
	
func _start_teleport(character : Character):
	# meant to start a scene transition and teleport mario to a different door, but for now just exits him out of the same door for testing
	character.position = self.global_position
	door_enter_logic.start_door_exit_animation(character)
