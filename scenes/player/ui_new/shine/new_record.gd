extends Label


onready var backing = $Backing
export var max_rotation: float = 3
export var rotation_speed: float = 3
var elapsed: float


func _process(delta: float):
	if is_visible_in_tree():
		elapsed += delta
		rect_rotation = sin(elapsed * rotation_speed) * max_rotation
		
		var outline_color := Color().from_hsv(wrapf(elapsed, 0, 1), 1, 0.3)
		add_color_override("font_outline_modulate", outline_color)
		backing.add_color_override("font_color", outline_color)
		backing.add_color_override("font_outline_modulate", outline_color)

func resized():
	rect_pivot_offset = rect_size / 2
