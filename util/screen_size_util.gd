class_name ScreenSizeUtil

const DEFAULT_SIZE = Vector2(768, 432)
const WIDTH_FACTOR = DEFAULT_SIZE.x / DEFAULT_SIZE.y

static func set_screen_size(window_scale):
	
	var window_size : Vector2 = DEFAULT_SIZE * window_scale
	var max_size = Vector2(OS.get_screen_size().x, OS.get_screen_size().y)
	
	var modified = false
	if window_size.x > max_size.x:
		window_scale = 3
	if window_size.y > max_size.y:
		window_scale = 3
	
	if window_scale != 3:
		OS.window_fullscreen = false
		OS.window_size = window_size
		OS.window_position = Vector2((max_size.x - OS.window_size.x) / 2, (max_size.y - OS.window_size.y) / 2)
	else:
		OS.window_fullscreen = true
