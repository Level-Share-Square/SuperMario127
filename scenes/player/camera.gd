extends Camera2D

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
var base_size = Vector2(393, 216)
var area
var shape
var in_cutscene: bool = false

var shake_strength: float = 0.0
var shake = false

const GP_ZOOM_IN = Vector2(0.025, 0.025)
var old_zoom: Vector2
var disable_gp_zoom: bool = false

var cutscene_queue: Array
var current_cutscene: CameraCutscene

onready var character_node = get_node(character)
onready var bg = get_node(background)
onready var zoom_tween: Tween = $ZoomTween
onready var cutscene_tween: Tween = $CutsceneTween

onready var viewport

var character_vel = Vector2(0, 0)

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


func _physics_process(delta):
	if !auto_move: 
		return
	
	if focus_on != null:
		position = position.linear_interpolate(focus_on.global_position, fps_util.PHYSICS_DELTA * 3)
		reset_physics_interpolation()
		bg.parallax_node.scroll_base_scale.y = zoom.y
	
	elif is_instance_valid(character_node):
		if !character_node.dead and !get_tree().paused:
			if character_node.controllable:
				character_vel = character_vel.linear_interpolate(character_node.velocity * 15.5 * delta, fps_util.PHYSICS_DELTA * 2)
			else:
				character_vel = Vector2()
			if is_instance_valid(bg):
				bg.parallax_node.scroll_base_scale.y = zoom.y
			if skip_to_player:
				yield(get_tree(), "idle_frame")
				reset_smoothing()
				skip_to_player = false
			shape.shape.extents = base_size * zoom.y
			size = shape.shape.extents
			last_position = global_position
			global_position = character_node.global_position + character_vel
			
			for stopper in area.get_overlapping_areas():
#				if global_position.y < stopper.top_bound.y + size.length().y * 1.2 or global_position.y > stopper.bottom_bound.y + size.length().y * 1.2 or global_position.x < stopper.left_bound.x + size.length().x * 1.2 or global_position.x > stopper.right_bound.x + size.length().x * 1.2:
				# this calculates if the camera is too far away from a horizontal or vertical edge and takes resized bounds into account
				# the same as what the code commented out above does
				
				if abs(global_position.y - stopper.global_position.y) < size.y * 1.2 + abs(stopper.top_bound.y - stopper.global_position.y) or abs(global_position.x - stopper.global_position.x) < size.x * 1.2 + abs(stopper.left_bound.x - stopper.global_position.x):
					var overlapX = min(abs(last_position.x + size.x - stopper.left_bound.x), abs(last_position.x - size.x - stopper.right_bound.x))
					var overlapY = min(abs(last_position.y + size.y - stopper.top_bound.y), abs(last_position.y - size.y - stopper.bottom_bound.y))
					
				
					if overlapX < overlapY:
#						print(overlapX)
#						print(overlapY)
						
						if last_position.x < stopper.global_position.x and global_position.x > last_position.x:
							global_position.x = stopper.left_bound.x - size.x + 1
						elif last_position.x > stopper.global_position.x and global_position.x < last_position.x:
							global_position.x = stopper.right_bound.x + size.x - 1
						else:
							pass
					else:
#						print(overlapX)
#						print(overlapY)
#						print(global_position.y > last_position.y)
						# top bound of stopper
						if last_position.y < stopper.global_position.y and global_position.y > last_position.y:
							global_position.y = stopper.top_bound.y - size.y + 1
						# bottom bound of stopper
						elif last_position.y > stopper.global_position.y and global_position.y < last_position.y:
							#print("botttom")
							#print(stopper.top_bound.y)
							#print(stopper.bottom_bound.y)
							global_position.y = stopper.bottom_bound.y + size.y - 1
						else:
							pass
				else:
					print("ESCAPED")
			
			if Singleton.PlayerSettings.player2_character == character_node.player_id:
						area.global_position = global_position
						
						
	if !zoom.is_equal_approx(old_zoom):
		zoom = lerp(zoom, old_zoom, 0.08)
	if shake == true:
		if round(shake_strength) > 0:
			shake_strength = lerp(shake_strength, 0, 0.2)
			offset = _get_random_offset()
		else:
			shake = false


func set_zoom_tween(target : Vector2, time : float, override = false):
	old_zoom = target
	current_zoom = target
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	zoom_tween.remove_all()
	# overrides level boundary safety check
	if override:
		zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
		disable_gp_zoom = true
		print(zoom_tween.connect("tween_all_completed", self, "on_zoom_tween_zoomed"))
		zoom_tween.start()
		return
	var level_size : Vector2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds.size * 16
	var intended_zoom = target * size
	
	var divide: float = size.y
	if divide == 0: divide = 0.0001
	var max_size = level_size.y/divide
	
	if intended_zoom.x > level_size.x:
		#target.x = clamp(target.x, target.x, level_size.x/size.x)
		max_size = (level_size.x/size.x)
	target = Vector2(min(target.x, max_size), min(target.y, max_size))
	zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
	disable_gp_zoom = true
	print(zoom_tween.connect("tween_all_completed", self, "on_zoom_tween_zoomed"))
	zoom_tween.start()

func on_zoom_tween_zoomed():
	disable_gp_zoom = false

func load_in(_level_data : LevelData, level_area : LevelArea):
	var level_bounds = level_area.settings.bounds
	limit_left = level_bounds.position.x * 32
	limit_top = level_bounds.position.y * 32
	limit_right = level_bounds.end.x * 32
	limit_bottom = level_bounds.end.y * 32
	
	
	if focus_on != null:
		position = focus_on.global_position
		reset_physics_interpolation()
	elif character_node != null:
		position = character_node.global_position
		reset_physics_interpolation()
		character_node.camera = self
	if Singleton.PlayerSettings.number_of_players == 2:
		base_size.x /= 2


func queue_cutscene(cutscene : CameraCutscene):
	cutscene_queue.append(cutscene)
	
#	print(cutscene_queue)
#	print(cutscene.owner.pause_mode)


func start_queue():
	if cutscene_queue.size() == 0:
		push_warning("No cutscene queue to start, queue a cutscene then call start_queue()!")
		return
	
	if !in_cutscene:
		in_cutscene = true
		play_cutscene(cutscene_queue[0])
		print("queue started!")
	


func play_cutscene(cutscene : CameraCutscene, reverse: bool = false):
	current_cutscene = cutscene
	
	pause_mode = PAUSE_MODE_PROCESS
	cutscene.owner.pause_mode = PAUSE_MODE_PROCESS
	get_tree().paused = true
	character_node.toggle_movement(false)
	Singleton.CurrentLevelData.can_pause = false
	
	var new_position = cutscene.to if !reverse else character_node.position
	var camera_distance = position.distance_to(new_position)
	
	if cutscene.cutscene_type == cutscene.Type.AUTO:
		if position.distance_to(new_position) <= 800:
			cutscene.cutscene_type = cutscene.Type.PAN
			cutscene.time = cutscene.time * (camera_distance/800)
		else:
			cutscene.cutscene_type = cutscene.Type.TRANSITION
	
	if cutscene.cutscene_type == cutscene.Type.PAN:
		cutscene_tween.remove_all()
		cutscene_tween.interpolate_property(
			self, 
			"position", 
			position, 
			new_position, 
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
		smoothing_enabled = false
		Singleton.SceneTransitions.do_transition_animation(
			Singleton.SceneTransitions.cutout_circle, 
			cutscene.time
			)
		yield(Singleton.SceneTransitions, "transition_finished")
		position = new_position
		yield(Singleton.SceneTransitions, "transition_finished")
		
		if cutscene.animation != "" and !reverse:
			cutscene.owner.animation_player.play(cutscene.animation)
			yield(cutscene.owner.animation_player, "animation_finished")
		
	update_cutscene_queue()

func _get_random_offset() -> Vector2:
	randomize()
	return Vector2(rand_range(-shake_strength, shake_strength), rand_range(-shake_strength, shake_strength))

func update_cutscene_queue():
	var last_cutscene: CameraCutscene = cutscene_queue.pop_front()
	
	if cutscene_queue.size() > 0:
		play_cutscene(cutscene_queue[0])
	elif is_instance_valid(last_cutscene):
		play_cutscene(last_cutscene, true)
	else:
		in_cutscene = false
		pause_mode = PAUSE_MODE_INHERIT
		get_tree().paused = false
		character_node.toggle_movement(true)
		smoothing_enabled = true
		Singleton.CurrentLevelData.can_pause = true
