extends GameObject

class_name TeleportObject

# ============================================
# | While I'm doing pipes, I might as well   |
# | revamp the teleportation system so we    |
# | can consolidate some of this mess.       |
# ============================================

#LOCAL = TP within the same area, REMOTE = TP to different area
const WAIT_TIME := 0.45
var teleportation_mode = true #true = remote, false = local
var area_id := 0
var object_type := "unknown"
var destination_tag := "default_teleporter"
var tp_pair : TeleportObject

## For older levels only
var pipe_tag : String = "none"
###

var tp_tween = Tween.new()

func ready():
	add_child(tp_tween)
	if teleportation_mode:
		connect_remote_members()
	else:
		connect_local_members()

func local_tp(entering_character : Character, entering):
	if entering:
		tp_pair = find_local_pair()
		#For now, you can't teleport to another object with the same tag but a different mode
		if tp_pair.teleportation_mode && teleportation_mode == false:
			tp_pair = self
		entering_character.global_position = tp_pair.global_position
		entering_character.camera.global_position = entering_character.global_position
		entering_character.camera.skip_to_player = true
		tp_tween.interpolate_callback(tp_pair, WAIT_TIME, "start_exit_anim", entering_character)
		tp_tween.start()

	else:
		entering_character.invulnerable = false
		entering_character.controllable = true
		entering_character.movable = true
		
	exit_local_teleport()

func find_local_pair():
	for i in Singleton.CurrentLevelData.level_data.vars.teleporters:
		if i[0] == destination_tag.to_lower() && i[1] != self:
			return i[1]
	return self

func get_character_screen_position(character : Character) -> Vector2:
	# Find the camera pos, clamped to its limits
	var camera_pos = character.camera.global_position
	camera_pos.x = clamp(camera_pos.x, character.camera.limit_left + 384, character.camera.limit_right - 216)
	camera_pos.y = clamp(camera_pos.y, character.camera.limit_top + 384, character.camera.limit_bottom - 216)
	# Return relative screen position
	return character.global_position - camera_pos + Vector2(384, 216)

func change_areas(entering_character : Character, entering):
	#TODO: REMOVE UPWARD CALLS ASAP
	var character = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character) #Holy crap this is bad
	var character2
	if is_instance_valid(get_tree().get_current_scene().get_node(get_tree().get_current_scene().character2)):
			character2 = get_tree().get_current_scene().get_node(get_tree().get_current_scene().character2)
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
		
		if character2 != null:
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
		entering_character.toggle_movement(true)
		
		exit_remote_teleport()

func connect_local_members():
	pass

func connect_remote_members():
	pass

func exit_local_teleport():
	pass

func exit_remote_teleport():
	pass

func _start_local_transition(character : Character, entering) -> void:
	if entering:
		# warning-ignore: return_value_discarded
		Singleton.SceneTransitions.connect("transition_finished", self, "local_tp", [character, true], CONNECT_ONESHOT)
		# sets the transition center to Mario's position
		Singleton.SceneTransitions.canvas_mask.global_position = get_character_screen_position(character)
		# this starts an inner scene transition, then connects a function (one shot) to start as it finishes
		Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, -1, -1, false, false)
	else:
		# sets the transition center to Mario's position
		Singleton.SceneTransitions.canvas_mask.global_position = get_character_screen_position(character)
		# this starts an inner scene transition, then connects a function (one shot) to start as it finishes
		Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, -1, -1, false, false)
