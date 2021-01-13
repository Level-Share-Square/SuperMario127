extends GameObject

onready var pipe_enter_logic = $PipeEnterLogic

var area_id := 0
var pipe_tag := "default"

func _set_properties():
	savable_properties = ["area_id", "pipe_tag"]
	editable_properties = ["area_id", "pipe_tag"]
	
func _set_property_values():
	set_property("area_id", area_id, true)
	set_property("pipe_tag", pipe_tag, true)

func _ready():
	pipe_enter_logic.connect("pipe_animation_finished", self, "change_areas")
	CurrentLevelData.level_data.vars.pipes.append([pipe_tag.to_lower(), self])

func change_areas(character, entering):
	if entering:
		CurrentLevelData.level_data.vars.transition_data = [
			"pipe", 
			pipe_tag
		]
		character.switch_areas(area_id, 0.5)
	else:
		character.invulnerable = false
		character.controllable = true
		character.movable = true
		
		pipe_enter_logic.is_idle = true

func start_exit_anim(character):
	pipe_enter_logic.start_pipe_exit_animation(character)

func get_bottom_distance():
	return pipe_enter_logic.PIPE_BOTTOM_DISTANCE
