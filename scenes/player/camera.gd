extends Camera2D

export var character : NodePath
export var background : NodePath
var focus_on : Node
var auto_move := true
var skip_to_player := true
var focus_zoom := 1.0
var last_position = Vector2(0,0)
var size = Vector2(0,0)

onready var character_node = get_node(character)
onready var bg = get_node(background)
onready var zoom_tween = $Tween
onready var area = $Area2D
onready var shape = $Area2D/CollisionShape2D
onready var viewport

var character_vel = Vector2(0, 0)

func _ready():
	area.connect("area_entered", self, "_on_area_entered")
	
func _physics_process(delta):
	if !auto_move: return
	if focus_on != null:
		position = position.linear_interpolate(focus_on.global_position, fps_util.PHYSICS_DELTA * 3)
		bg.parallax_node.scroll_base_scale.y = zoom.y
		#zoom = zoom.linear_interpolate(Vector2(focus_zoom, focus_zoom), fps_util.PHYSICS_DELTA * 3)
		
	elif is_instance_valid(character_node):
		if !character_node.dead and !get_tree().paused:
			if character_node.controllable:
				character_vel = character_vel.linear_interpolate(character_node.velocity * 15.5 * delta, fps_util.PHYSICS_DELTA * 2)
			else:
				character_vel = Vector2()
			
			bg.parallax_node.scroll_base_scale.y = zoom.y
			if skip_to_player:
				yield(get_tree(), "idle_frame")
				reset_smoothing()
				skip_to_player = false
			
			size = shape.shape.extents
			last_position = global_position
			global_position = character_node.global_position + character_vel
			for stopper in area.get_overlapping_areas():
#				print("global pos")
#				print(global_position.x + size.x)
#				print(last_position.x + size.x)
#				print(stopper.left_bound.x)
#				print(stopper.right_bound.x)
#				print(stopper.global_position)
				#GLOBAL POSITION IS IN THE CENTER OF THE CAMERA REMEMBER THIS
				if last_position.x + size.x > stopper.left_bound.x and last_position.x + size.x < stopper.right_bound.x and global_position.x > last_position.x and !(global_position.x - size.x > stopper.right_bound.x):
					print("left intersect")
					global_position.x = stopper.left_bound.x - size.x + 1
				elif last_position.x - size.x < stopper.right_bound.x and last_position.x - size.x > stopper.left_bound.x and global_position.x < last_position.x and !(global_position.x + size.x < stopper.left_bound.x):
					global_position.x = stopper.right_bound.x + size.x - 1
					print("right intersect")
#					print("hi")
#					if !last_position.x < stopper.right_bound.x:
#						global_position.x = stopper.right_bound.x
#						print("reset")
#					else:
#						print("false")
#						print(last_position.x)
#						print(global_position.x)
#						print(stopper.right_bound.x)
				elif last_position.y + size.y > stopper.top_bound.y and last_position.y + size.y < stopper.bottom_bound.y and global_position.y > last_position.y and !(global_position.y - size.y > stopper.bottom_bound.y):
					global_position.y = stopper.top_bound.y - size.y + 1
					print("top intersect")
#					if !last_position.y - size.y < stopper.top_bound.y:
#						global_position.y = stopper.top_bound.y - size.y
#						print("reset")
				elif last_position.y - size.y < stopper.bottom_bound.y and last_position.y - size.y > stopper.top_bound.y and global_position.y < last_position.y and !(global_position.y + size.y < stopper.top_bound.y):
					print("bottom intersect")
					global_position.y = stopper.bottom_bound.y + size.y - 1
#					if !last_position.y > stopper.bottom_bound.y:
#						global_position.y = stopper.bottom_bound.y
#						print("reset")
				else:
					print(global_position.y)
					print(last_position.y)
					print(stopper.bottom_bound.y)
					print(stopper.top_bound.y)
				
			
			
			
			
			
			
			
func _on_area_entered(stopper):
	pass
	return
func set_zoom_tween(target : Vector2, time : float):
	zoom_tween.interpolate_property(self, "zoom", zoom, target, time, 1, 0)
	zoom_tween.start()

	
func load_in(_level_data : LevelData, level_area : LevelArea):
	var level_bounds = level_area.settings.bounds
	limit_left = level_bounds.position.x * 32
	limit_top = level_bounds.position.y * 32
	limit_right = level_bounds.end.x * 32
	limit_bottom = level_bounds.end.y * 32
	
	
	if focus_on != null:
		position = focus_on.global_position
	elif character_node != null:
		position = character_node.global_position
		character_node.camera = self
