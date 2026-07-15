class_name WarpHelper
extends Node


const WAIT_TIME := 0.25
const CAMERA_TWEEN_TIME := 0.5
onready var teleporter: GameObject = get_parent()
var timer_manager

export var play_warp_sound: bool = true # for level warping specifically
export var one_way: bool = false # if true, won't bring mario back to the warp when returning from hub
export var hide_character: bool = true
export var set_position: bool = true


### WARP FUNCTIONS ####
func location_warp(character: Character, target_tag: String, max_pan_distance: int) -> void:
	var target_teleporter: GameObject = find_teleporter(target_tag)
	var tween: Tween
	var do_pan: bool = teleporter.global_position.distance_to(target_teleporter.global_position) < max_pan_distance
	if do_pan:
		character.camera.auto_move = false
		
		var end_point: Vector2 = target_teleporter.global_position
		if CurrentLevelData.vars.area_transition_helper != null and target_teleporter is AreaTransition:
			end_point = CurrentLevelData.vars.area_transition_helper.find_camera_position(
				target_teleporter.vertical, 
				target_teleporter.global_position, 
				character.camera.base_size, 
				target_teleporter.parts * 32
			)
		
		tween = Tween.new()
		add_child(tween)
		
		tween.interpolate_property(character.camera, "position", null, end_point, CAMERA_TWEEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	else:
		transition_in(character)
		yield(Singleton.SceneTransitions, "transition_finished")
	
	yield(get_tree().create_timer(WAIT_TIME), "timeout")
	
	if hide_character:
		character.hide()
	if set_position:
		character.global_position = target_teleporter.global_position
		character.reset_physics_interpolation()
	
	if do_pan:
		yield(tween, "tween_all_completed")
		tween.queue_free()
		character.camera.last_position = character.camera.position
		character.camera.auto_move = true
	else:
		character.camera.skip_to_player = true
		character.camera.global_position = character.global_position
		transition_out(character)
		
	target_teleporter.start_exit_animation(character)


func area_warp(character: Character, target_tag: String, target_area: int) -> void:
#	if is_instance_valid(timer_manager):
#		if (area_id == CurrentLevelData.area):
#
#			var area_timer: Control = timer_manager.get_timer("area_timer")
#
#			if (is_instance_valid(area_timer) && area_timer.time < .65):
#				# Don't chage the area if the area timer is too low.
#				# Ideally the time left would just be carried over after reloading the area.
#				# This only happens when the player teleports from and to the same area.
#				return
#		else:
#			timer_manager.remove_timer("area_timer")
#	else:
#		printerr("Couldn't find timer manager node!")
	
	# band aid crash fix
	while CurrentLevelData.level_data.vars.liquid_positions.size() <= CurrentLevelData.area:
		CurrentLevelData.level_data.vars.liquid_positions.append([])
	
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
	if !is_instance_valid(character.state):
		character.state = character.get_state_node("FallState")
	
	CurrentLevelData.level_data.vars.transition_character_data = [
		character.health,
		character.health_shards,
		nozzle_name,
		character.fuel,
		powerup_array,
		get_tree().get_current_scene().switch_timer
	]
#	if object_type == "area_transition":
#		CurrentLevelData.level_data.vars.transition_character_data.append(AreaTransitionHelper.new(character.velocity, character.state, character.facing_direction, to_local(character.position), self.vertical))
	
	CurrentLevelData.level_data.vars.transition_character_data_2 = []
	
#	CurrentLevelData.level_data.vars.transition_data = [
#		object_type, 
#		target_tag,
#		teleportation_mode
#	]
	CurrentLevelData.level_data.vars.transition_data = {"target_tag": target_tag}
	character.switch_areas(target_area, 0.5)


## setting target area to -1 will enter mario into the level normally, other
## values will skip the shine select and exit mario out of a specific teleport object
func level_warp(character: Character, target_level: String, 
				target_tag: String, target_area: int = -1) -> void:
	
	var level_id: String = target_level
	var working_folder: String = CurrentLevelData.working_folder
	var level_info: LevelInfo = Singleton.SceneSwitcher.load_level_info(level_id, working_folder)
	
	var hub_level: String = CurrentLevelData.hub_level
	var selected_file: int = CurrentLevelData.selected_file
	
	if target_area != -1:
		CurrentLevelData.level_transition_data = {
			"target_area": target_area, "target_tag": target_tag}
	else:
		CurrentLevelData.level_transition_data = {}
	
	if CurrentLevelData.is_hub_level():
		if one_way:
			CurrentLevelData.hub_return_data = {}
		else:
			CurrentLevelData.hub_return_data = {
				"target_area": CurrentLevelData.area, "target_tag": target_tag}
			
	
	Singleton.Music.reset_music()
	Singleton.Music.stop()
	Singleton.SceneSwitcher.start_level(level_info, level_id, working_folder, false, false, hub_level, true, play_warp_sound, selected_file)


### OTHER ###
func find_teleporter(target_tag: String) -> GameObject:
	for i in CurrentLevelData.vars.teleporters:
		if i[0] == target_tag.to_lower() && i[1] != teleporter:
			return i[1]
	return teleporter


func transition_in(character: Character) -> void:
	# sets the transition center to Mario's position
	Singleton.SceneTransitions.canvas_mask.global_position = get_character_screen_position(character)
	Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, -1, -1, false)


func transition_out(character: Character) -> void:
	# sets the transition center to Mario's position
	Singleton.SceneTransitions.canvas_mask.global_position = get_character_screen_position(character)
	Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, -1, -1, false)


func get_character_screen_position(character : Character) -> Vector2:
	# Find the camera pos, clamped to its limits
	var camera_pos = character.camera.global_position
	camera_pos.x = clamp(camera_pos.x, character.camera.limit_left + 384, character.camera.limit_right - 216)
	camera_pos.y = clamp(camera_pos.y, character.camera.limit_top + 384, character.camera.limit_bottom - 216)
	# Return relative screen position
	return character.global_position - camera_pos + Vector2(384, 216)
