class_name WarpHelper
extends Node


const WAIT_TIME := 0.25
const CAMERA_TWEEN_TIME := 0.5
onready var teleporter: GameObject = get_parent()

### WARP FUNCTIONS ####
func location_warp(character: Character, target_tag: String, max_pan_distance: int) -> void:
	var target_teleporter: GameObject = find_teleporter(target_tag)
	var tween: Tween
	var do_pan: bool = teleporter.global_position.distance_to(target_teleporter.global_position) < max_pan_distance
	if do_pan:
		var end_point = target_teleporter.global_position
		tween = Tween.new()
		add_child(tween)
		
		tween.interpolate_property(character.camera, "position", null, end_point, CAMERA_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
	else:
		transition_in(character)
		yield(Singleton.SceneTransitions, "transition_finished")
	
	yield(get_tree().create_timer(WAIT_TIME), "timeout")
	
	character.global_position = target_teleporter.global_position
	character.reset_physics_interpolation()
	
	if do_pan:
		yield(tween, "tween_all_completed")
		tween.queue_free()
	else:
		character.camera.skip_to_player = true
		character.camera.global_position = character.global_position
		transition_out(character)
		
	target_teleporter.start_exit_animation(character)


func area_warp(character: Character, target_tag: String, target_area: int) -> void:
	pass


## setting target area to -1 will enter mario into the level normally, other
## values will skip the shine select and exit mario out of a specific teleport object
func level_warp(character: Character, target_level: String, 
				target_tag: String, target_area: int = -1) -> void:
	
	var level_id: String = target_level
	var working_folder: String = Singleton.CurrentLevelData.working_folder
	var level_info: LevelInfo = Singleton.SceneSwitcher.load_level_info(level_id, working_folder)
	
	var hub_level: String = Singleton.CurrentLevelData.hub_level
	var is_campaign: bool = Singleton.CurrentLevelData.is_campaign
	
	Singleton.Music.reset_music()
	Singleton.Music.stop()
	Singleton.SceneSwitcher.menu_return_screen = "LevelsList"
	Singleton.SceneSwitcher.menu_return_args = [level_info, level_id, working_folder, false, is_campaign]
	Singleton.SceneSwitcher.start_level(level_info, level_id, working_folder, false, false, hub_level)


### OTHER ###
func find_teleporter(target_tag: String) -> GameObject:
	for i in Singleton.CurrentLevelData.level_data.vars.teleporters:
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
