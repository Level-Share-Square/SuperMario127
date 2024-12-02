extends Camera2D

export var speed = 12.0
var up_held = false
var down_held = false
var left_held = false
var right_held = false

var lerp_speed = 30.0
var default_height

func _unhandled_input(event):
	if event.is_action_pressed("editor_up"):
		up_held = true
	elif event.is_action_released("editor_up"):
		up_held = false
	
	if event.is_action_pressed("editor_down"):
		down_held = true
	elif event.is_action_released("editor_down"):
		down_held = false
		
	if event.is_action_pressed("editor_left"):
		left_held = true
	elif event.is_action_released("editor_left"):
		left_held = false
		
	if event.is_action_pressed("editor_right"):
		right_held = true
	elif event.is_action_released("editor_right"):
		right_held = false


func load_in(_level_data : LevelData, level_area : LevelArea):
	var zoom_level = Singleton.EditorSavedSettings.zoom_level
	position.x = (get_viewport_rect().size.x / 2) * zoom_level
	position.y = (level_area.settings.bounds.end.y * 32) - ((get_viewport_rect().size.y / 2) * zoom_level)
	for object in level_area.objects:
		if is_instance_valid(object) and object is LevelObject:
			if object.type_id == 0:
				position = object.properties[0] # properties[0] is always position, at least for spawners
	
	update_limits(level_area)
	reset_smoothing()
	
	zoom = Vector2(zoom_level, zoom_level)
	


func update_limits(level_area : LevelArea):	
	var area_bounds = level_area.settings.bounds.grow(3)

	limit_left  = int(area_bounds.position.x * 32)
	limit_top   = int(area_bounds.position.y * 32 - 70 * zoom.x) #needs to include the toolbar

	limit_right  = int(area_bounds.end.x * 32)
	limit_bottom = int(area_bounds.end.y * 32)

	resolve_limit_collisions()
	
func resolve_limit_collisions():
	var camera_left = position.x - ((get_viewport_rect().size.x / 2) * zoom.x)
	var camera_right = position.x + ((get_viewport_rect().size.x / 2) * zoom.x)
	var camera_up = position.y - ((get_viewport_rect().size.y / 2) * zoom.y)
	var camera_down = position.y + ((get_viewport_rect().size.y / 2) * zoom.y)
	
	if camera_left < limit_left:
		position.x = limit_left + ((get_viewport_rect().size.x / 2) * zoom.x)
	if camera_right > limit_right:
		position.x = limit_right - ((get_viewport_rect().size.x / 2) * zoom.x)
	if camera_up < limit_top:
		position.y = limit_top + ((get_viewport_rect().size.y / 2) * zoom.y)
	if camera_down > limit_bottom:
		position.y = limit_bottom - ((get_viewport_rect().size.y / 2) * zoom.y)

func _physics_process(delta):
	var move_speed = speed * 2 if Input.is_action_pressed("speed_up_camera") else speed
	
	var move_dir := Vector2.ZERO
	
	# to make sure it doesnt just move around when selecting text boxes or doing anything important
	if up_held or down_held or left_held or right_held:
		move_dir = Input.get_vector("editor_left", "editor_right", "editor_up", "editor_down")
	

	position += move_dir*move_speed*60*delta
	resolve_limit_collisions()
		
	var editor = get_tree().get_current_scene()
	if(zoom.x != editor.zoom_level):
		var zoom_level = editor.zoom_level
		zoom = zoom.linear_interpolate(Vector2(zoom_level, zoom_level), delta * lerp_speed)
		update_limits(Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area])

func _ready():
	default_height = get_viewport_rect().size.y
