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
	if rotation != 0 and enabled:
		enabled = false
	pipe_enter_logic.connect("pipe_animation_finished", self, "change_areas")
	if rotation == 0:
		Singleton.CurrentLevelData.level_data.vars.pipes.append([pipe_tag.to_lower(), self])

func _process(delta):
	if rotation != 0 and enabled:
		enabled = false
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

func change_areas(entering_character : Character, entering):
	var character = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character)
	if area_id >= Singleton.CurrentLevelData.level_data.areas.size():
		area_id = Singleton.CurrentLevelData.area
	if entering:
		Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area] = []
		for liquid in Singleton.CurrentLevelData.level_data.vars.liquids:
			Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area].append(liquid[1].save_pos)
		
		var powerup_array = [null, null, null]
		if is_instance_valid(character.powerup):
			powerup_array[0] = character.powerup.name
			powerup_array[1] = character.powerup.time_left
			powerup_array[2] = character.powerup.play_temp_music
		
		var nozzle_name = null
		if character.nozzle != null:
			nozzle_name = character.nozzle.name
		
		Singleton.CurrentLevelData.level_data.vars.transition_character_data = [
			character.health,
			character.health_shards,
			nozzle_name,
			character.fuel,
			powerup_array,
			get_tree().get_current_scene().switch_timer
		]
		
		if is_instance_valid(get_tree().get_current_scene().character2):
			var character2 = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character2)
			var nozzle_name_2 = null
			if character2.nozzle != null:
				nozzle_name_2 = character2.nozzle.name
			
			var powerup_array2 = [null, null, null]
			if is_instance_valid(character2.powerup):
				powerup_array2[0] = character2.powerup.name
				powerup_array2[1] = character2.powerup.time_left
				powerup_array2[2] = character2.powerup.play_temp_music
			
			Singleton.CurrentLevelData.level_data.vars.transition_character_data_2 = [
				character2.health,
				character2.health_shards,
				nozzle_name_2,
				character2.fuel,
				powerup_array2,
				get_tree().get_current_scene().switch_timer
			]
		else:
			Singleton.CurrentLevelData.level_data.vars.transition_character_data_2 = []

		Singleton.CurrentLevelData.level_data.vars.transition_data = [
			"pipe", 
			pipe_tag
		]
		entering_character.switch_areas(area_id, 0.5)
	else:
		entering_character.invulnerable = false
		entering_character.controllable = true
		entering_character.movable = true
		
		pipe_enter_logic.is_idle = true

func start_exit_anim(character):
	pipe_enter_logic.start_pipe_exit_animation(character)

func get_bottom_distance():
	return pipe_enter_logic.PIPE_BOTTOM_DISTANCE - 30
