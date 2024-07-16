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
		
		
		tp_tween.interpolate_callback(tp_pair, WAIT_TIME, "start_exit_anim", entering_character)
		tp_tween.start()
		if object_type == "area_transition" and tp_pair.object_type == "area_transition":
			return
			
		entering_character.camera.global_position = entering_character.global_position
		entering_character.camera.skip_to_player = true

	else:
		entering_character.invulnerable = false
		entering_character.controllable = true
		entering_character.movable = true
		
		
	exit_local_teleport()

func find_local_pair():
	for i in Singleton.CurrentLevelData.level_data.vars.teleporters:
		if i[0] == destination_tag.to_lower() && i[1] != self && !i[1].teleportation_mode:
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
		if !is_instance_valid(character.state):
			character.state = character.get_state_node("FallState")
		
		Singleton.CurrentLevelData.level_data.vars.transition_character_data = [
			character.health,
			character.health_shards,
			nozzle_name,
			character.fuel,
			powerup_array,
			get_tree().get_current_scene().switch_timer
		]
		if object_type == "area_transition":
			Singleton.CurrentLevelData.level_data.vars.transition_character_data.append(AreaTransitionHelper.new(character.velocity, character.state, character.facing_direction, to_local(character.position), self.vertical))
		
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
			if object_type == "area_transition":
				Singleton.CurrentLevelData.level_data.vars.transition_character_data_2.append(AreaTransitionHelper.new(character2.velocity, character2.state, character2.facing_direction, to_local(character2.position), self.vertical))
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
	var local_pair = find_local_pair()
	if entering:
		# warning-ignore: return_value_discardedt
		print(global_position.distance_to(local_pair.global_position))
		if global_position.distance_to(local_pair.global_position) <= 800:

			var tween = Tween.new()
			add_child(tween)
			tween.connect("tween_all_completed", self, "local_tp", [character, true], CONNECT_ONESHOT)
			character.sprite.visible = false
			var camera = character.camera
			var end_point = local_pair.position
			if object_type == "area_transition" and local_pair.object_type == "area_transition":
				camera.auto_move = false
				if local_pair.stops_camera:
					print("true")
					end_point = Singleton.CurrentLevelData.level_data.vars.transition_character_data.back().find_camera_position(local_pair.vertical, local_pair.global_position, camera.base_size, local_pair.parts * 32)
					character.sprite.visible = true
					
				else:
					end_point = Singleton.CurrentLevelData.level_data.vars.transition_character_data.back().find_exit_offset(local_pair.vertical, local_pair.parts * 32) + local_pair.global_position
				print(end_point)
			tween.interpolate_property(camera, "position", null, end_point, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
			
			
		else:
			Singleton.SceneTransitions.connect("transition_finished", self, "local_tp", [character, true], CONNECT_ONESHOT)
			# sets the transition center to Mario's position
			Singleton.SceneTransitions.canvas_mask.global_position = get_character_screen_position(character)
			# this starts an inner scene transition, then connects a function (one shot) to start as it finishes
			Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, -1, -1, false, false)
			if local_pair.object_type == "area_transition":
				if local_pair.stops_camera:
					character.camera.auto_move = false
	else:
		
		character.sprite.visible = true
		if global_position.distance_to(local_pair.global_position) > 800:
			if object_type == "area_transition":
				if self.stops_camera:
					Singleton.SceneTransitions.connect("transition_finished", self, "_dumb_method", [character], CONNECT_ONESHOT)
			# sets the transition center to Mario's position
			Singleton.SceneTransitions.canvas_mask.global_position = get_character_screen_position(character)
			# this starts an inner scene transition, then connects a function (one shot) to start as it finishes
			Singleton.SceneTransitions.do_transition_animation(Singleton.SceneTransitions.cutout_circle, Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Singleton.SceneTransitions.TRANSITION_SCALE_COVERED, Singleton.SceneTransitions.TRANSITION_SCALE_UNCOVER, -1, -1, false, false)
		else:
			character.camera.auto_move = true
		
			
			
			
		
class AreaTransitionHelper:
	var velocity
	var state
	var facing_direction
	var enter_pos
	var vertical

	func _init(ve, s, f, e : Vector2, v):
		velocity = ve
		state = s
		facing_direction = f
		enter_pos = e
		vertical = v
		
	func find_exit_offset(exit_vertical : bool, exit_size : float) -> Vector2:
		if exit_vertical:
			return Vector2(32 *  sign(velocity.x), -clamp(-enter_pos.y, -exit_size/2, exit_size/2))
		else:
			return Vector2(clamp(enter_pos.x, -exit_size/2, exit_size/2), 16 * -sign(velocity.y))
			
	func find_camera_position(exit_vertical : bool, exit_global_position : Vector2, camera_rect : Vector2, exit_size : float):
		if exit_vertical:
			return exit_global_position + Vector2((camera_rect.x + 50) * sign(velocity.x), find_exit_offset(exit_vertical, exit_size).y)
		else:
			return exit_global_position + Vector2(find_exit_offset(exit_vertical, exit_size).x, (camera_rect.y + 50) * sign(velocity.y))
		return exit_global_position + Vector2((camera_rect.x + 16) * sign(velocity.x), (camera_rect.y) + 16 * -sign(velocity.y))  * Vector2(int(!exit_vertical), int(exit_vertical))
		
