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

onready var character_node = get_node(character)
onready var bg = get_node(background)
onready var zoom_tween = $ZoomTween
onready var pan_tween = $PanTween

onready var viewport

var character_vel = Vector2(0, 0)

func _ready():
	if is_instance_valid(character_node) && character_node.player_id == 1:
		shape = get_node(character2_cam_collider).get_node("CollisionShape2D")
		area = get_node(character2_cam_collider)
	else:
		shape = $Area2D/CollisionShape2D
		area = $Area2D
	area.connect("area_entered", self, "_on_area_entered")
func _physics_process(delta):
	if !auto_move: return
	if focus_on != null:
		position = position.linear_interpolate(focus_on.global_position, fps_util.PHYSICS_DELTA * 3)
		reset_physics_interpolation()
		bg.parallax_node.scroll_base_scale.y = zoom.y
		#zoom = zoom.linear_interpolate(Vector2(focus_zoom, focus_zoom), fps_util.PHYSICS_DELTA * 3)
		
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
			
			
			
func _on_area_entered(stopper):
	pass
	return
func set_zoom_tween(target : Vector2, time : float, override = false):
	current_zoom = target
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	zoom_tween.remove_all()
	# overrides level boundary safety check
	if override:
		zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
		zoom_tween.start()
		return
	var level_size : Vector2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds.size * 16
	var intended_zoom = target * size
	var max_size = level_size.y/size.y
	if intended_zoom.x > level_size.x:
		#target.x = clamp(target.x, target.x, level_size.x/size.x)
		max_size = (level_size.x/size.x)
	target = Vector2(min(target.x, max_size), min(target.y, max_size))
	zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
	zoom_tween.start()

#THIS FUNCTION DOES NOT WORK. DO NOT CALL IT, IT WILL CAUSE THE GAME TO FREEZE.
#SOMEONE WILL NEED TO FIX IT TO MAKE IT NOT FREEZE THE GAME.
func set_pan_tween(target : Vector2, time : float, override = false):
	auto_move = false
	pan_tween.remove_all()
	# overrides level boundary safety check
	if override:
		pan_tween.interpolate_property(self, "pan", position, target, time, 1, 0)
		pan_tween.start()
		return
	var level_bounds : Vector2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds.size * 16
	target = Vector2(clamp(target.x, 0+(size.x/2), level_bounds.x-(size.x/2)), clamp(target.y, 0+(size.x/2), level_bounds.y-(size.x/2)))
	pan_tween.interpolate_property(self, "pan", position, target, time, 1, 0)
	pan_tween.start()
	
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
