extends Camera2D

export var speed = 5
var up_held = false
var down_held = false
var left_held = false
var right_held = false

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
	position.x = get_viewport_rect().size.x / 2
	position.y = (level_area.settings.size.y * 32) - (get_viewport_rect().size.y / 2)
	update_limits(level_area)
	
func update_limits(level_area : LevelArea):	
	limit_right = int(level_area.settings.size.x * 32)
	limit_bottom = int(level_area.settings.size.y * 32)
	
func check_borders():
	var camera_left = position.x - (get_viewport_rect().size.x / 2)
	var camera_right = position.x + (get_viewport_rect().size.x / 2)
	var camera_up = position.y - (get_viewport_rect().size.y / 2)
	var camera_down = position.y + (get_viewport_rect().size.y / 2)
	
	if camera_left < limit_left:
		position.x = limit_left + (get_viewport_rect().size.x / 2)
	if camera_right > limit_right:
		position.x = limit_right - (get_viewport_rect().size.x / 2)
	if camera_up < limit_top:
		position.y = limit_top + (get_viewport_rect().size.y / 2)
	if camera_down > limit_bottom:
		position.y = limit_bottom - (get_viewport_rect().size.y / 2)

func _physics_process(_delta):
	if up_held:
		position.y -= speed
		check_borders()
	elif down_held:
		position.y += speed
		check_borders()
	if left_held:
		position.x -= speed
		check_borders()
	elif right_held:
		position.x += speed
		check_borders()
