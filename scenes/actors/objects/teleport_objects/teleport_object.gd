extends GameObject

class_name TeleportObject

# ============================================
# | While I'm doing pipes, I might as well   |
# | revampthe teleportation system so we can |
# | consolidate some of this mess.           |
# ============================================

enum TELEPORT_MODE{LOCAL, REMOTE} #LOCAL = TP within the same level, REMOTE = TP to different level

var teleportation_mode = TELEPORT_MODE.LOCAL
var area_id := 0
var destination_tags : PoolStringArray = []

func _ready():
	match teleportation_mode:
		TELEPORT_MODE.REMOTE:
			connect_remote_members()
		TELEPORT_MODE.LOCAL:
			connect_local_members()

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

func connect_local_members():
	pass

func connect_remote_members():
	pass
