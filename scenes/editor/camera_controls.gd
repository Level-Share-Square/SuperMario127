extends Camera2D

export var speed = 5

func load_in(level_data : LevelData, level_area : LevelArea):
	position.x = get_viewport_rect().size.x / 2
	position.y = (level_area.settings.size.y * 32) - (get_viewport_rect().size.y / 2)
	
	limit_right = level_area.settings.size.x * 32
	limit_bottom = level_area.settings.size.y * 32
	
func check_borders():
	var camera_left = position.x - (get_viewport_rect().size.x / 2)
	var camera_right = position.x + (get_viewport_rect().size.x / 2)
	var camera_up = position.y - (get_viewport_rect().size.y / 2)
	var camera_down = position.y + (get_viewport_rect().size.y / 2)
	
	if camera_left < limit_left:
		position.x = get_viewport_rect().size.x / 2
	if camera_right > limit_right:
		position.x = limit_right - (get_viewport_rect().size.x / 2)
	if camera_up < limit_top:
		position.y = get_viewport_rect().size.y / 2
	if camera_down > limit_bottom:
		position.y = limit_bottom - (get_viewport_rect().size.y / 2)

func _physics_process(delta):
	if Input.is_action_pressed("editor_up"):
		position.y -= speed
		check_borders()
	elif Input.is_action_pressed("editor_down"):
		position.y += speed
		check_borders()
	if Input.is_action_pressed("editor_left"):
		position.x -= speed
		check_borders()
	elif Input.is_action_pressed("editor_right"):
		position.x += speed
		check_borders()
