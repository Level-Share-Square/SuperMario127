extends Camera2D


const CENTER_OFFSET: float = 96.0
const GROUND_OFFSET: float = -48.0
const CROUCH_OFFSET: float = 80.0

const X_MARGIN: float = 32.0
const X_FULL_MARGIN: float = 144.0

const X_SLOW_FOLLOW_SPEED: float = 2.0
const X_FOLLOW_SPEED: float = 6.0

const X_SPEED_THRESHOLD: float = 120.0
const X_MAX_SPEED: float = 500.0
const X_MAX_LEAD_DISTANCE: float = 320.0
const X_LEAD_SPEED: float = 1.0

const Y_FOLLOW_SPEED: float = 3.0
const Y_FAST_FOLLOW_SPEED: float = 5.0
const Y_DESPERATE_FOLLOW_SPEED: float = 6.0

const Y_SLOW_CORRECT_SPEED: float = 2.0
const Y_CORRECT_SPEED: float = 9.0
const Y_DESPERATE_CORRECT_SPEED: float = 24.0

const Y_OFFSET_SPEED: float = 4.0

const Y_SPEED_THRESHOLD_UP: float = 400.0
const Y_SPEED_THRESHOLD_DOWN: float = 200.0
const Y_MAX_SPEED: float = 800.0
const Y_MAX_LEAD_DISTANCE_Y: float = 400.0
const Y_LEAD_SPEED: float = 8.0

const STOPPER_EASE_T: float = 0.05

export var character : NodePath
export var background : NodePath
export var character2_cam_collider : NodePath
var focus_on : Node
var auto_move := true
var skip_to_player := true
var focus_zoom := 1.0
var current_zoom := Vector2(1.0, 1.0)
var last_position = Vector2(0,0)
var size = Vector2(0,0)
var base_size = Vector2(384, 216)
var level_bounds: Rect2
var area
var shape
var in_cutscene: bool = false
var did_pause: bool = true
var locked_movement: bool = true

var shake_strength: float = 0.0
var shake = false

const GP_ZOOM_IN = Vector2(0.025, 0.025)
const HURT_ZOOM_IN = Vector2(0.025, 0.025)
var old_zoom: Vector2
var disable_zoom_effect: bool = false

var cutscene_queue: Array
var current_cutscene: CameraCutscene

onready var character_node: Character = get_node(character)
onready var bg = get_node(background)
onready var zoom_tween: Tween = $ZoomTween
onready var cutscene_tween: Tween = $CutsceneTween

onready var viewport

var character_vel = Vector2(0, 0)
var current_lead_offset: float = 0.0
var current_lead_offset_y: float = 0.0
var y_baseline: float = 0.0
var y_offset: float = 0.0
var cur_baseline: float = 0.0

func _ready():
	in_cutscene = false
	old_zoom = zoom
	
	if is_instance_valid(character_node) && character_node.player_id == 1:
		shape = get_node(character2_cam_collider).get_node("CollisionShape2D")
		area = get_node(character2_cam_collider)
	else:
		shape = $Area2D/CollisionShape2D
		area = $Area2D
	area.connect("area_entered", self, "_on_area_entered")
	
	if is_instance_valid(character_node):
		yield(character_node, "loaded")
		global_position = character_node.global_position
		last_position = global_position
		y_baseline = global_position.y
		cur_baseline = y_baseline
		y_offset = GROUND_OFFSET

func _physics_process(delta):
	last_position = global_position
	update_shape_size()
	
	if auto_move:
		if focus_on != null:
			position = position.linear_interpolate(focus_on.global_position, fps_util.PHYSICS_DELTA * 3)
			bg.parallax_node.scroll_base_scale.y = zoom.y
		
		elif is_instance_valid(character_node):
			if !character_node.dead and !get_tree().paused:
				if is_instance_valid(bg):
					bg.parallax_node.scroll_base_scale.y = zoom.y
				
				if skip_to_player:
					global_position = character_node.global_position
					last_position = global_position
					y_baseline = global_position.y
					cur_baseline = y_baseline
					y_offset = GROUND_OFFSET
					skip_to_player = false
				
				var char_screen_pos: Vector2 = character_node.get_canvas_transform().xform(character_node.global_position)
				var char_center_distance: Vector2 = char_screen_pos - (base_size * zoom.y)
				
				## x axis
				var char_velocity_x: float = character_node.velocity.x
				var char_speed_x: float = abs(char_velocity_x)
				
				var target_lead_offset: float = 0.0
				if char_speed_x > X_SPEED_THRESHOLD:
					var speed_factor: float = clamp((char_speed_x - X_SPEED_THRESHOLD) / (X_MAX_SPEED - X_SPEED_THRESHOLD), 0.0, 1.0)
					target_lead_offset = X_MAX_LEAD_DISTANCE * zoom.y * speed_factor * sign(char_velocity_x)
				
				current_lead_offset = lerp(current_lead_offset, target_lead_offset, delta * X_LEAD_SPEED)
				
				var target_x: float = character_node.global_position.x + current_lead_offset
				var x_delta: float = target_x - global_position.x
				
				if abs(x_delta) > X_MARGIN:
					var clamped_delta: float = x_delta - (sign(x_delta) * X_MARGIN)
					var follow_speed: float = X_FOLLOW_SPEED
					if abs(x_delta) < X_FULL_MARGIN:
						var diff: float = X_FOLLOW_SPEED - X_SLOW_FOLLOW_SPEED
						var margin_diff: float = X_FULL_MARGIN - X_MARGIN
						var distance_to_edge: float = (abs(x_delta) - X_MARGIN) / margin_diff
						follow_speed = X_SLOW_FOLLOW_SPEED + (diff*distance_to_edge)
					global_position.x = lerp(global_position.x, global_position.x + clamped_delta, delta * follow_speed)
				
				## y axis
				var char_velocity_y: float = character_node.velocity.y
				var char_speed_y: float = abs(char_velocity_y)
				
				var target_lead_offset_y: float = 0.0
				var threshold: float = Y_SPEED_THRESHOLD_UP if char_velocity_y < 0 else Y_SPEED_THRESHOLD_DOWN
				if char_speed_y > threshold:
					var y_speed_factor: float = clamp((char_speed_y - threshold) / (Y_MAX_SPEED - threshold), 0.0, 1.0)
					target_lead_offset_y = Y_MAX_LEAD_DISTANCE_Y * zoom.y * y_speed_factor * sign(char_velocity_y)
				
				current_lead_offset_y = lerp(current_lead_offset_y, target_lead_offset_y, delta * Y_LEAD_SPEED)
				
				var y_dist_abs: float = abs(char_center_distance.y)
				if y_dist_abs > abs(size.y/4) and not character_node.is_grounded():
					var target_y: float = character_node.global_position.y + current_lead_offset_y
					
					var t: float = clamp(y_dist_abs / abs(size.y), 0.0, 2.0)
					var correct_speed: float = smoothstep(Y_SLOW_CORRECT_SPEED, Y_DESPERATE_CORRECT_SPEED, t * Y_DESPERATE_CORRECT_SPEED)
					if t < 1.0:
						correct_speed = lerp(Y_SLOW_CORRECT_SPEED, Y_CORRECT_SPEED, ease(t, 2.0))
					else:
						correct_speed = lerp(Y_CORRECT_SPEED, Y_DESPERATE_CORRECT_SPEED, ease(min((t - 1.0), 1.0), 0.5))
					
					y_baseline = lerp(y_baseline, target_y, delta * correct_speed)
					y_offset = lerp(y_offset, 0, delta * Y_OFFSET_SPEED)
					cur_baseline = y_baseline
				
				elif is_instance_valid(character_node.state) and character_node.state.force_cam_follow_y:
					y_baseline = character_node.global_position.y + current_lead_offset_y
					y_offset = lerp(y_offset, 0, delta * Y_OFFSET_SPEED)
					
				elif character_node.is_grounded():
					var translated_transform: Transform2D = character_node.transform.translated(Vector2(0, 96))
					if character_node.inputs[9][0] and abs(character_node.velocity.x) < 10:
						y_offset = lerp(y_offset, CROUCH_OFFSET, delta * Y_OFFSET_SPEED)
					else:
						y_offset = lerp(y_offset, GROUND_OFFSET, delta * Y_OFFSET_SPEED)
					y_baseline = character_node.global_position.y + current_lead_offset_y
				
				var follow_t: float = clamp(y_dist_abs / max(size.y, 0.0001), 0.0, 2.0)
				var y_follow: float = lerp(Y_DESPERATE_FOLLOW_SPEED, Y_FOLLOW_SPEED, ease(min(follow_t, 1.0), 1.5))
				if follow_t > 1.0:
					y_follow = lerp(Y_FOLLOW_SPEED, Y_FAST_FOLLOW_SPEED, ease(min(follow_t - 1.0, 1.0), 0.5))
				
				var t: float = clamp(y_dist_abs / (abs(size.y) + 0.0001), 0.0, 2.0)
				var update_speed: float = smoothstep(Y_SLOW_CORRECT_SPEED, Y_DESPERATE_CORRECT_SPEED, t * Y_DESPERATE_CORRECT_SPEED)
				if t < 1.0:
					update_speed = lerp(Y_SLOW_CORRECT_SPEED, Y_CORRECT_SPEED, ease(t, 2.0))
				else:
					update_speed = lerp(Y_CORRECT_SPEED, Y_DESPERATE_CORRECT_SPEED, ease(min((t - 1.0), 1.0), 0.5))
				
				cur_baseline = lerp(cur_baseline, y_baseline, delta * update_speed)
				global_position.y = lerp(global_position.y - y_offset, cur_baseline, delta * y_follow)
				global_position.y += y_offset
		
		if !zoom.is_equal_approx(old_zoom) and !zoom_tween.is_active():
			zoom = lerp(zoom, old_zoom, 0.08)
		if shake == true:
			if round(shake_strength) > 0:
				shake_strength = lerp(shake_strength, 0, 0.2)
				offset = _get_random_offset()
			else:
				shake = false
	
	update_shape_size()
	global_position = clamp_position(global_position, last_position, size)


func update_shape_size() -> void:
	if not zoom_tween.is_active():
		var level_total_bounds := Vector2(level_bounds.size.x, level_bounds.size.y)
		var max_zoom: float = min(level_total_bounds.x / (base_size.x*2), level_total_bounds.y / (base_size.y*2))
		zoom.x = min(zoom.y, max_zoom)
		zoom.y = min(zoom.y, max_zoom)
	
	shape.shape.extents = base_size * zoom.y
	size = base_size * zoom.y


func clamp_position(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, exclude_areas: Array = []) -> Vector2:
	new_pos = clamp_to_level_bounds(new_pos, cur_size)
	
	var compare_areas: Array = area.get_overlapping_areas()
	for exclude_area in exclude_areas:
		if exclude_area in compare_areas:
			compare_areas.erase(exclude_area)
	
	for stopper in compare_areas:
		if in_cutscene: return new_pos
		if not is_near_stopper(new_pos, cur_size, stopper):
			print("ESCAPED")
			continue
		new_pos = resolve_stopper(new_pos, last_pos, cur_size, stopper)
	
	return new_pos


func clamp_to_level_bounds(new_pos: Vector2, cur_size: Vector2) -> Vector2:
	if new_pos.x - cur_size.x < level_bounds.position.x:
		new_pos.x = level_bounds.position.x + cur_size.x
	if new_pos.x + cur_size.x > level_bounds.position.x + level_bounds.size.x:
		new_pos.x = level_bounds.position.x + level_bounds.size.x - cur_size.x
	if new_pos.y - cur_size.y < level_bounds.position.y:
		new_pos.y = level_bounds.position.y + cur_size.y
	if new_pos.y + cur_size.y > level_bounds.position.y + level_bounds.size.y:
		new_pos.y = level_bounds.position.y + level_bounds.size.y - cur_size.y
	return new_pos


func is_near_stopper(new_pos: Vector2, cur_size: Vector2, stopper: CameraStopper) -> bool:
	var near_y: bool = abs(new_pos.y - stopper.global_position.y) < cur_size.y * 1.2 + abs(stopper.top_bound.y - stopper.global_position.y)
	var near_x: bool = abs(new_pos.x - stopper.global_position.x) < cur_size.x * 1.2 + abs(stopper.left_bound.x - stopper.global_position.x)
	return near_y or near_x


func resolve_stopper(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, stopper: CameraStopper) -> Vector2:
	var char_pos: Vector2 = character_node.global_position
	var in_vband: bool = char_pos.x >= stopper.left_bound.x and char_pos.x <= stopper.right_bound.x
	var in_hband: bool = char_pos.y >= stopper.top_bound.y and char_pos.y <= stopper.bottom_bound.y
	
	if in_vband and not in_hband:
		return resolve_vertical_route(new_pos, last_pos, cur_size, stopper, char_pos)
	elif in_hband and not in_vband:
		return resolve_horizontal_route(new_pos, last_pos, cur_size, stopper, char_pos)
	else:
		return resolve_ambiguous_route(new_pos, last_pos, cur_size, stopper)


func resolve_vertical_route(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, stopper: CameraStopper, char_pos: Vector2) -> Vector2:
	if char_pos.y < stopper.top_bound.y and new_pos.y + cur_size.y > stopper.top_bound.y:
		var target_y: float = stopper.top_bound.y - cur_size.y + 1
		if zoom_tween.is_active():
			new_pos.y = target_y
		else:
			new_pos.y = CatmullRomSpline.sample([last_pos, Vector2(new_pos.x, target_y)], STOPPER_EASE_T).y
			
	elif char_pos.y > stopper.bottom_bound.y and new_pos.y - cur_size.y < stopper.bottom_bound.y:
		var target_y: float = stopper.bottom_bound.y + cur_size.y - 1
		if zoom_tween.is_active():
			new_pos.y = target_y
		else:
			new_pos.y = CatmullRomSpline.sample([last_pos, Vector2(new_pos.x, target_y)], STOPPER_EASE_T).y
			
	return new_pos


func resolve_horizontal_route(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, stopper: CameraStopper, char_pos: Vector2) -> Vector2:
	if char_pos.x < stopper.left_bound.x and new_pos.x + cur_size.x > stopper.left_bound.x:
		var target_x: float = stopper.left_bound.x - cur_size.x + 1
		if zoom_tween.is_active():
			new_pos.x = target_x
		else:
			new_pos.x = CatmullRomSpline.sample([last_pos, Vector2(target_x, new_pos.y)], STOPPER_EASE_T).x
	elif char_pos.x > stopper.right_bound.x and new_pos.x - cur_size.x < stopper.right_bound.x:
		var target_x: float = stopper.right_bound.x + cur_size.x - 1
		if zoom_tween.is_active():
			new_pos.x = target_x
		else:
			new_pos.x = CatmullRomSpline.sample([last_pos, Vector2(target_x, new_pos.y)], STOPPER_EASE_T).x
	return new_pos


func resolve_ambiguous_route(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, stopper: CameraStopper) -> Vector2:
	var overlap_x: float = min(abs(last_pos.x + cur_size.x - stopper.left_bound.x), abs(last_pos.x - cur_size.x - stopper.right_bound.x))
	var overlap_y: float = min(abs(last_pos.y + cur_size.y - stopper.top_bound.y), abs(last_pos.y - cur_size.y - stopper.bottom_bound.y))
	
	if overlap_x < overlap_y:
		return resolve_ambiguous_x(new_pos, last_pos, cur_size, stopper)
	else:
		return resolve_ambiguous_y(new_pos, last_pos, cur_size, stopper)


func resolve_ambiguous_x(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, stopper: CameraStopper) -> Vector2:
	if last_pos.x < stopper.global_position.x and new_pos.x > last_pos.x:
		var clamped_x: float = stopper.left_bound.x - cur_size.x + 1
		if zoom_tween.is_active():
			new_pos.x = clamped_x
		else:
			new_pos.x = CatmullRomSpline.sample([last_pos, Vector2(clamped_x, new_pos.y)], STOPPER_EASE_T).x
	elif last_pos.x > stopper.global_position.x and new_pos.x < last_pos.x:
		var clamped_x: float = stopper.right_bound.x + cur_size.x - 1
		if zoom_tween.is_active():
			new_pos.x = clamped_x
		else:
			new_pos.x = CatmullRomSpline.sample([last_pos, Vector2(clamped_x, new_pos.y)], STOPPER_EASE_T).x
	return new_pos


func resolve_ambiguous_y(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, stopper: CameraStopper) -> Vector2:
	if last_pos.y < stopper.global_position.y and new_pos.y > last_pos.y:
		var clamped_y: float = stopper.top_bound.y - cur_size.y + 1
		if zoom_tween.is_active():
			new_pos.y = clamped_y
		else:
			new_pos.y = CatmullRomSpline.sample([last_pos, Vector2(new_pos.x, clamped_y)], STOPPER_EASE_T).y
	elif last_pos.y > stopper.global_position.y and new_pos.y < last_pos.y:
		var clamped_y: float = stopper.bottom_bound.y + cur_size.y - 1
		if zoom_tween.is_active():
			new_pos.y = clamped_y
		else:
			new_pos.y = CatmullRomSpline.sample([last_pos, Vector2(new_pos.x, clamped_y)], STOPPER_EASE_T).y
	return new_pos


func set_zoom_tween(target : Vector2, time : float):
	var level_total_bounds := Vector2(level_bounds.position.x + level_bounds.size.x, level_bounds.position.y + level_bounds.size.y)
	var max_zoom: float = min(level_total_bounds.x / (base_size.x*2), level_total_bounds.y / (base_size.y*2))
	target.x = min(target.x, max_zoom)
	target.y = min(target.y, max_zoom)
	
	old_zoom = target
	current_zoom = target
	zoom_tween.remove_all()
	var level_size : Vector2 = CurrentLevelData.current_area.header.bounds.size * 16
	var intended_zoom = target * size
	
	var divide: float = size.y
	if divide == 0: divide = 0.0001
	var max_size = level_size.y/divide
	
	if intended_zoom.x > level_size.x:
		max_size = (level_size.x/size.x)
	target = Vector2(min(target.x, max_size), min(target.y, max_size))
	zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
	disable_zoom_effect = true
	zoom_tween.connect("tween_all_completed", self, "on_zoom_tween_zoomed", [], CONNECT_ONESHOT)
	zoom_tween.start()

func on_zoom_tween_zoomed():
	disable_zoom_effect = false

func load_in():
	level_bounds = CurrentLevelData.current_area.header.bounds
	level_bounds.position *= 32
	level_bounds.size *= 32
	
	if focus_on != null:
#		position = focus_on.global_position
		reset_physics_interpolation()
	elif character_node != null:
#		position = character_node.global_position
		reset_physics_interpolation()
		character_node.camera = self
	if Singleton.PlayerSettings.number_of_players == 2:
		base_size.x /= 2


func queue_cutscene(cutscene : CameraCutscene):
	cutscene_queue.append(cutscene)


func start_queue():
	if cutscene_queue.size() == 0:
		push_warning("No cutscene queue to start, queue a cutscene then call start_queue()!")
		return
	
	if !in_cutscene:
		in_cutscene = true
		play_cutscene(cutscene_queue.pop_front())

func play_cutscene(cutscene : CameraCutscene, reverse: bool = false):
	current_cutscene = cutscene

	did_pause = false
	locked_movement = false
	if cutscene.lock_movement:
		locked_movement = true
		character_node.toggle_movement(false)
	if cutscene.do_pause:
		did_pause = true
		pause_mode = PAUSE_MODE_PROCESS
		cutscene.owner.pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = true
		CurrentLevelData.can_pause = false
	auto_move = false
	
	var new_position = cutscene.to if !reverse else character_node.position
	new_position = clamp_position(new_position, last_position, size, cutscene.exclude_stoppers)
	
	var compare_position: Vector2 = global_position
	if cutscene.from != Vector2.INF:
		compare_position = cutscene.from
	
	var camera_distance = compare_position.distance_to(new_position)
	if cutscene.cutscene_type == cutscene.Type.AUTO:
		if compare_position.distance_to(new_position) <= cutscene.max_pan_distance:
			cutscene.cutscene_type = cutscene.Type.PAN
			if cutscene.do_time_scaling:
				cutscene.time = cutscene.time * (camera_distance/cutscene.max_pan_distance)
		else:
			cutscene.cutscene_type = cutscene.Type.TRANSITION
	
	if cutscene.cutscene_type == cutscene.Type.PAN:
		var err: int = yield(pan_to(new_position, cutscene), "completed")
		
		if err == ERR_BUG:
			cutscene.cutscene_type = cutscene.Type.TRANSITION
			play_cutscene(cutscene, false)
			return
		
		if cutscene.animation != "" and !reverse:
			cutscene.owner.animation_player.play(cutscene.animation)
			yield(cutscene.owner.animation_player, "animation_finished")
	
	elif cutscene.cutscene_type == cutscene.Type.TRANSITION:
		if cutscene.from_character:
			SceneTransitions.canvas_mask.global_position = get_character_screen_position()
		SceneTransitions.do_transition_animation(
			SceneTransitions.cutout_circle, 
			cutscene.time
			)
		yield(SceneTransitions, "transition_finished")
		y_baseline = new_position.y
		cur_baseline = new_position.y
		last_position = new_position
		global_position = new_position
		if cutscene.from_character:
			SceneTransitions.canvas_mask.global_position = get_character_screen_position()
		
		if cutscene.animation != "" and !reverse:
			cutscene.owner.animation_player.play(cutscene.animation)
			yield(cutscene.owner.animation_player, "animation_finished")
		
	if cutscene.do_reverse and cutscene_queue.empty() and not reverse:
		play_cutscene(cutscene, true)
		return
		
	update_cutscene_queue()
	
func pan_to(final_position: Vector2, cutscene: CameraCutscene) -> int:
	yield(get_tree(), "idle_frame") # Force coroutine
	
	var path: Array = find_path(global_position, final_position)
	if -1 in path:
		return ERR_BUG
		
	while path:
		var next_point: Vector2 = path.pop_front()
		pan_tween_to(next_point, cutscene)
		yield(cutscene_tween, "tween_completed")
		
	return OK
	
const INT32_MAX: int = 2147483647
	
func pan_tween_to(new_position: Vector2, cutscene: CameraCutscene):
	cutscene_tween.remove_all()
	cutscene_tween.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		new_position, 
		cutscene.time, 
		cutscene.transition_type, 
		cutscene.tween_ease
		)
	cutscene_tween.interpolate_property(
		self, 
		"last_position", 
		last_position, 
		new_position, 
		cutscene.time, 
		cutscene.transition_type, 
		cutscene.tween_ease
		)
	if abs(global_position.y - new_position.y) > 50:
		cutscene_tween.interpolate_property(
			self, 
			"y_baseline", 
			y_baseline, 
			new_position.y, 
			cutscene.time, 
			cutscene.transition_type, 
			cutscene.tween_ease
			)
		cutscene_tween.interpolate_property(
			self, 
			"cur_baseline", 
			cur_baseline, 
			new_position.y, 
			cutscene.time, 
			cutscene.transition_type, 
			cutscene.tween_ease
			)
	cutscene_tween.start()
	
func find_path(init_pos: Vector2, final_pos: Vector2, visited_corners = null, depth: int = 0) -> Array:
	if not visited_corners:
		visited_corners = {}
	if depth > 20: return [-1]
		
	var space_state: Physics2DDirectSpaceState = get_world_2d().direct_space_state
	var hit: Dictionary = space_state.intersect_ray(init_pos, final_pos, [], INT32_MAX, false, true)
	if not hit: return [final_pos]
	if not hit.collider is CameraStopper: return []
	
	var corners: Array = hit.collider.get_valid_corners(hit.normal)
	var best_corner: Vector2 = corners[0]
	var alt_corner: Vector2 = corners[1]
	if corners[1].distance_to(final_pos) < corners[0].distance_to(final_pos):
			best_corner = corners[1]
			alt_corner = corners[0]

	var snap_best = best_corner.snapped(Vector2(5.0, 5.0))
	var snap_alt = alt_corner.snapped(Vector2(5.0, 5.0))
	
	var best_is_visited: bool = visited_corners.has(snap_best)
	var alt_is_visited: bool = visited_corners.has(snap_alt)

	if best_is_visited and alt_is_visited:
		return [-1]
	elif best_is_visited:
		visited_corners[snap_alt] = true
		return [alt_corner] + find_path(alt_corner, final_pos, visited_corners, depth + 1)
	else:
		visited_corners[snap_best] = true
		return [best_corner] + find_path(best_corner, final_pos, visited_corners, depth + 1)
		
func _get_random_offset() -> Vector2:
	randomize()
	return Vector2(rand_range(-shake_strength, shake_strength), rand_range(-shake_strength, shake_strength))

func update_cutscene_queue():
	var last_cutscene: CameraCutscene = cutscene_queue.pop_front()
	
	if is_instance_valid(last_cutscene):
		play_cutscene(last_cutscene)
	else:
		in_cutscene = false
		if did_pause:
			pause_mode = PAUSE_MODE_INHERIT
			get_tree().paused = false
			CurrentLevelData.can_pause = true
		if locked_movement:
			character_node.toggle_movement(true)
		auto_move = true

func get_character_screen_position() -> Vector2:
	if not is_instance_valid(character_node): return global_position
	return character_node.global_position - global_position + size
