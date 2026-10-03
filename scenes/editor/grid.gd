extends ParallaxBackground

onready var parallax_scroll = $"%ParallaxScroll"
onready var grid_repeat = $"%GridRepeat"
onready var grid_texture = $"%GridTexture"

var hidden: bool = false
var camera_zoom_level: float = 1.0

const DEFAULT_MIRRORING = Vector2(3072, 1664)


func toggle_grid(value: bool = not hidden):
	hidden = value
	update_visibility(camera_zoom_level)


func update_visibility(zoom_level: float):
	camera_zoom_level = zoom_level
	
	if zoom_level > 4:
		visible = false
	else:
		visible = not hidden

func _process(delta):
	grid_repeat.motion_offset = parallax_scroll.position
	grid_repeat.motion_mirroring = DEFAULT_MIRRORING * parallax_scroll.scale
	grid_texture.rect_scale = parallax_scroll.scale

