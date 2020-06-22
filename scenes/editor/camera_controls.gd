extends Camera2D

export var speed = 6.0
var up_held = false
var down_held = false
var left_held = false
var right_held = false

var lerp_speed = 15
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
	var zoom_level = EditorSavedSettings.zoom_level
	position.x = (get_viewport_rect().size.x / 2) * zoom_level
	position.y = (level_area.settings.size.y * 32) - ((get_viewport_rect().size.y / 2) * zoom_level)
	update_limits(level_area)
	force_update_scroll()
	
	zoom = Vector2(zoom_level, zoom_level)
	limit_top = -70 * zoom_level
	
func update_limits(level_area : LevelArea):	
	limit_right = int(level_area.settings.size.x * 32)
	limit_bottom = int(level_area.settings.size.y * 32)
	
func check_borders():
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

	var editor = get_tree().get_current_scene()
	var zoom_level = editor.zoom_level
	#zoom = zoom.linear_interpolate(Vector2(zoom_level, zoom_level), delta * lerp_speed)
	limit_top = -70 * zoom_level

func _ready():
	get_tree().get_root().connect("size_changed", self, "resize")
	default_height = get_viewport_rect().size.y
	
func resize():
	var new_zoom = default_height/get_viewport_rect().size.y
	set_zoom(Vector2(new_zoom, new_zoom))
