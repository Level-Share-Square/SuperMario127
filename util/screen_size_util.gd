class_name ScreenSizeUtil

const DEFAULT_SIZE = Vector2(768, 432)
const WIDTH_FACTOR = DEFAULT_SIZE.x / DEFAULT_SIZE.y

static func set_screen_size(window_scale):
	OS.window_fullscreen = window_scale == 5
	
	var window_size : Vector2 = DEFAULT_SIZE * window_scale
	var max_size = Vector2(OS.get_screen_size().x, OS.get_screen_size().y)
	
	var modified = false
	if window_size.x > max_size.x:
		OS.window_size = Vector2(max_size.x, max_size.x / WIDTH_FACTOR)
		modified = true
	if window_size.y > max_size.y:
		OS.window_size = Vector2(max_size.y * WIDTH_FACTOR, max_size.y)
		modified = true
	
	if !modified:
		OS.window_size = window_size
	
	OS.window_position = Vector2((max_size.x - OS.window_size.x) / 2, (max_size.y - OS.window_size.y) / 2)
