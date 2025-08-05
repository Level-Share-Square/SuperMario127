extends TextureRect

var pressed = false

onready var whiteY = 0
onready var blackY = get_rect().size.y
onready var gradient_selector = get_node("Gradient Selector")
onready var color_wheel = get_parent().get_node("Wheel")
onready var new_color_preview = get_parent().get_node("ColorPreviews/NewColorPreview")

var value = 1

signal updated

func _input(event):
	if get_parent().get_parent().get_parent().rect_min_size.y == 0:
		return
	 
	var center = get_rect().size/2
	var is_in_rect = get_rect().has_point(get_local_mouse_position())
	
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		pressed = event.pressed && get_local_mouse_position().x < 18 && get_local_mouse_position().y < 120 && get_local_mouse_position() > Vector2.ZERO
	
	if !pressed:
		return
	
	gradient_selector.rect_position.y = clamp(get_local_mouse_position().y, whiteY, blackY)
	value = (gradient_selector.rect_position.y - blackY) / (whiteY - blackY)
	color_wheel.self_modulate = Color(value, value, value)
	modulate = color_wheel.base_color
	modulate.v = value
	var new_color = color_wheel.base_color
	new_color.v = value
	color_wheel.emit_signal("updated", new_color)

func set_brightness(brightness):
	gradient_selector.rect_position.y = lerp(blackY, whiteY, brightness)
	value = brightness
