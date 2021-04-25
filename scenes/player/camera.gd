extends Camera2D

export var character : NodePath
var focus_on : Node
var auto_move := true
var skip_to_player := true
var focus_zoom := 1.0

onready var character_node = get_node(character)

var character_vel = Vector2(0, 0)
func _physics_process(delta):
	if !auto_move: return
	
	if focus_on != null:
		position = position.linear_interpolate(focus_on.global_position, fps_util.PHYSICS_DELTA * 3)
		zoom = zoom.linear_interpolate(Vector2(focus_zoom, focus_zoom), fps_util.PHYSICS_DELTA * 3)
	elif is_instance_valid(character_node):
		if !character_node.dead and !get_tree().paused:
			if character_node.controllable:
				character_vel = character_vel.linear_interpolate(character_node.velocity * 15.5 * delta, fps_util.PHYSICS_DELTA * 2)
			else:
				character_vel = Vector2()
			
			position = character_node.global_position + character_vel
			
			if skip_to_player:
				yield(get_tree(), "idle_frame")
				reset_smoothing()
				skip_to_player = false

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
