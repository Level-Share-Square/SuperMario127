extends Sprite

var pressed = false

onready var whiteY = -(get_rect().size.y / 2)
onready var blackY = -whiteY
onready var gradient_selector = get_node("Gradient Selector")
onready var color_wheel = get_parent().get_node("Wheel")
onready var new_color_preview = get_parent().get_node("ColorPreviews/NewColorPreview")
onready var color_manager = color_wheel.get_node("Color")

var value = 1

func _input(event):
	if !color_wheel.get_parent().get_parent().visible:
		return
	 
	var is_in_rect = get_rect().has_point(get_local_mouse_position())
	
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		pressed = event.pressed && is_in_rect
	
	if !pressed:
		return
	
	gradient_selector.position.y = clamp(get_local_mouse_position().y, whiteY, blackY)
	value = (gradient_selector.position.y - blackY) / (whiteY - blackY)
	color_wheel.self_modulate = Color(value, value, value)
	
	var new_color = color_manager.get_value()
	new_color.v = value
	color_manager.set_value(new_color)
	new_color_preview.modulate = new_color
	color_wheel.notify_property_manager()

func set_brightness(brightness):
	gradient_selector.position.y = lerp(blackY, whiteY, brightness)
	value = brightness
