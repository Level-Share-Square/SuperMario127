extends GameObject

onready var pipe_enter_logic = $PipeEnterLogic
onready var sprite = $Sprite
onready var sprite2 = $Sprite/Sprite2

export var normal_texture : Texture
export var recolorable_texture : Texture 

var area_id := 0
var pipe_tag := "default"
var color := Color(0, 1, 0)

func _set_properties():
	savable_properties = ["area_id", "pipe_tag", "color"]
	editable_properties = ["area_id", "pipe_tag", "color"]
	
func _set_property_values():
	set_property("area_id", area_id, true)
	set_property("pipe_tag", pipe_tag, true)
	set_property("color", color, true)

func _ready():
	pipe_enter_logic.connect("pipe_animation_finished", self, "change_areas")
	CurrentLevelData.level_data.vars.pipes.append([pipe_tag.to_lower(), self])

func _process(delta):
	if enabled:
		rotation = 0
	if color == Color(0, 1, 0):
		sprite.texture = normal_texture
		sprite.self_modulate = Color(1, 1, 1)
	else:
		sprite.texture = recolorable_texture
		sprite2.visible = true
		sprite.self_modulate = color
		var bright_color = color
		bright_color.s /= 1.5
		bright_color.v *= 1.15
		sprite2.self_modulate = bright_color

func change_areas(character : Character, entering):
	if area_id >= CurrentLevelData.level_data.areas.size():
		area_id = CurrentLevelData.area
	if entering:
		CurrentLevelData.level_data.vars.liquid_positions[CurrentLevelData.area] = []
		for liquid in CurrentLevelData.level_data.vars.liquids:
			CurrentLevelData.level_data.vars.liquid_positions[CurrentLevelData.area].append(liquid[1].save_pos)
		
		var powerup_array = [null, null, null]
		if is_instance_valid(character.powerup):
			powerup_array[0] = character.powerup.name
			powerup_array[1] = character.powerup.time_left
			powerup_array[2] = character.powerup.play_temp_music
		
		var nozzle_name = null
		if character.nozzle != null:
			nozzle_name = character.nozzle.name
		
		CurrentLevelData.level_data.vars.transition_character_data = [
			character.health,
			character.health_shards,
			nozzle_name,
			character.fuel,
			powerup_array,
			get_tree().get_current_scene().switch_timer
		]
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
	return pipe_enter_logic.PIPE_BOTTOM_DISTANCE - 30
