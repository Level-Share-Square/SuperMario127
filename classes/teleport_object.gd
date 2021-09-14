extends GameObject

class_name TeleportObject

# ============================================
# | While I'm doing pipes, I might as well   |
# | revamp the teleportation system so we    |
# | can consolidate some of this mess.       |
# ============================================

#LOCAL = TP within the same area, REMOTE = TP to different area

var teleportation_mode = true #true = remote, false = local
var area_id := 0
var object_type := "unknown"
var destination_tag := "default_teleporter"

func ready():
	if teleportation_mode:
		connect_remote_members()
	else:
		connect_local_members()

func local_tp(entering_character : Character, entering):
	#TODO: REMOVE UPWARD CALLS ASAP
	var character = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character) #Holy crap this is bad
	if Singleton.CurrentLevelData.level_data.tags:
		
		if entering:
			
			Singleton.CurrentLevelData.level_data.vars.transition_data = [
				object_type, 
				destination_tag,
				teleportation_mode
			]

		else:
			entering_character.invulnerable = false
			entering_character.controllable = true
			entering_character.movable = true
			
			exit_remote_teleport()

func change_areas(entering_character : Character, entering):
	#TODO: REMOVE UPWARD CALLS ASAP
	var character = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character) #Holy crap this is bad
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
			object_type, 
			destination_tag,
			teleportation_mode
		]
		entering_character.switch_areas(area_id, 0.5)
	else:
		entering_character.invulnerable = false
		entering_character.controllable = true
		entering_character.movable = true
		
		exit_remote_teleport()

func connect_local_members():
	pass

func connect_remote_members():
	pass

func exit_local_teleport():
	pass

func exit_remote_teleport():
	pass
