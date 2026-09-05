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
var did_pause: bool = false
var locked_movement: bool = false

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
	
	if not zoom_tween.is_active():
		var level_total_bounds := Vector2(level_bounds.position.x + level_bounds.size.x, level_bounds.position.y + level_bounds.size.y)
		var max_zoom: float = min(level_total_bounds.x / (base_size.x*2), level_total_bounds.y / (base_size.y*2))
		zoom.x = min(zoom.y, max_zoom)
		zoom.y = min(zoom.y, max_zoom)
	
	shape.shape.extents = base_size * zoom.y
	size = shape.shape.extents
	
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
				var y_dist_abs: float = abs(char_center_distance.y)
				if y_dist_abs > abs(size.y/4) and not character_node.is_grounded():
					var target_y: float = character_node.global_position.y
					
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
					y_baseline = character_node.global_position.y
					y_offset = lerp(y_offset, 0, delta * Y_OFFSET_SPEED)
					
				elif character_node.is_grounded():
					var translated_transform: Transform2D = character_node.transform.translated(Vector2(0, 96))
					if character_node.inputs[9][0] and abs(character_node.velocity.x) < 10:
						y_offset = lerp(y_offset, CROUCH_OFFSET, delta * Y_OFFSET_SPEED)
					else:
						y_offset = lerp(y_offset, GROUND_OFFSET, delta * Y_OFFSET_SPEED)
					y_baseline = character_node.global_position.y
				
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
		
		if !zoom.is_equal_approx(old_zoom):
			zoom = lerp(zoom, old_zoom, 0.08)
		if shake == true:
			if round(shake_strength) > 0:
				shake_strength = lerp(shake_strength, 0, 0.2)
				offset = _get_random_offset()
			else:
				shake = false
	
	global_position = clamp_position(global_position, last_position, size)


func clamp_position(new_pos: Vector2, last_pos: Vector2, cur_size: Vector2, exclude_areas: Array = []) -> Vector2:
	# level bounds
	if new_pos.x - cur_size.x < level_bounds.position.x:
		new_pos.x = level_bounds.position.x + cur_size.x
	if new_pos.x + cur_size.x > level_bounds.size.x:
		new_pos.x = level_bounds.size.x - cur_size.x

	if new_pos.y - cur_size.y < level_bounds.position.y:
		new_pos.y = level_bounds.position.y + cur_size.y
	if new_pos.y + cur_size.y > level_bounds.size.y:
		new_pos.y = level_bounds.size.y - cur_size.y
	
	# stoppers
	var compare_areas: Array = area.get_overlapping_areas()
	for exclude_area in exclude_areas:
		if exclude_area in compare_areas:
			compare_areas.erase(exclude_area)
	for stopper in compare_areas:
		if abs(new_pos.y - stopper.global_position.y) < cur_size.y * 1.2 + abs(stopper.top_bound.y - stopper.global_position.y) or abs(new_pos.x - stopper.global_position.x) < cur_size.x * 1.2 + abs(stopper.left_bound.x - stopper.global_position.x):
			var overlapX = min(abs(last_pos.x + cur_size.x - stopper.left_bound.x), abs(last_pos.x - cur_size.x - stopper.right_bound.x))
			var overlapY = min(abs(last_pos.y + cur_size.y - stopper.top_bound.y), abs(last_pos.y - cur_size.y - stopper.bottom_bound.y))
			
			if overlapX < overlapY:
				if last_pos.x < stopper.global_position.x and new_pos.x > last_pos.x:
					new_pos.x = stopper.left_bound.x - cur_size.x + 1
				elif last_pos.x > stopper.global_position.x and new_pos.x < last_pos.x:
					new_pos.x = stopper.right_bound.x + cur_size.x - 1
			else:
				# top bound of stopper
				if last_pos.y < stopper.global_position.y and new_pos.y > last_pos.y:
					new_pos.y = stopper.top_bound.y - cur_size.y + 1
				# bottom bound of stopper
				elif last_pos.y > stopper.global_position.y and new_pos.y < last_pos.y:
					new_pos.y = stopper.bottom_bound.y + cur_size.y - 1
		else:
			print("ESCAPED")
	
	return new_pos


func set_zoom_tween(target : Vector2, time : float, override = false):
	var level_total_bounds := Vector2(level_bounds.position.x + level_bounds.size.x, level_bounds.position.y + level_bounds.size.y)
	var max_zoom: float = min(level_total_bounds.x / (base_size.x*2), level_total_bounds.y / (base_size.y*2))
	target.x = min(target.x, max_zoom)
	target.y = min(target.y, max_zoom)
	
	old_zoom = target
	current_zoom = target
	zoom_tween.remove_all()
	# overrides level boundary safety check
	if override:
		zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
		disable_zoom_effect = true
		zoom_tween.connect("tween_all_completed", self, "on_zoom_tween_zoomed")
		zoom_tween.start()
		return
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
	zoom_tween.connect("tween_all_completed", self, "on_zoom_tween_zoomed")
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

		yield(cutscene_tween, "tween_completed")

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
		yield(SceneTransitions, "transition_finished")
		
		if cutscene.animation != "" and !reverse:
			cutscene.owner.animation_player.play(cutscene.animation)
			yield(cutscene.owner.animation_player, "animation_finished")
		
	if cutscene.do_reverse and cutscene_queue.empty() and not reverse:
		play_cutscene(cutscene, true)
		return
		
	update_cutscene_queue()

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
