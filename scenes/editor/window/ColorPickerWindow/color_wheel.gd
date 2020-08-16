extends Sprite

var pressed = false

onready var selector = $"HSV Color Selector"
onready var gradient_selector = get_parent().get_node("Gradient")
onready var new_color_preview = get_parent().get_node("ColorPreviews/NewColorPreview")
onready var color_manager = $Color

var property_node : Node
var base_color : Color # color without transparency

func _input(event):
	if !get_parent().get_parent().visible:
		return
	
	var mouse_pos = get_local_mouse_position()
	var normal_coordinates = (mouse_pos) / get_rect().size.x * 2
	
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		pressed = event.pressed && normal_coordinates.length() <= 1
	
	if !pressed:
		return
	
	normal_coordinates = normal_coordinates.normalized() * min(normal_coordinates.length(), 1)	
	mouse_pos = mouse_pos.normalized() * min(mouse_pos.length(), get_rect().size.x * 0.5)
	
	# Is in sprite - check if its in the circle
	selector.position = mouse_pos
	base_color = Color.from_hsv(atan2(normal_coordinates.x, normal_coordinates.y) / (2*PI), normal_coordinates.length(), gradient_selector.value)
	gradient_selector.modulate = base_color
	new_color_preview.modulate = base_color
	color_manager.set_value(base_color)
	notify_property_manager()

func update_value(color : Color):
	var length := get_rect().size.x * color.s / 2
	var angle := color.h*2*PI
	selector.position = Vector2(sin(angle)*length, cos(angle)*length)
	gradient_selector.modulate = color
	new_color_preview.modulate = color
	self_modulate = Color(color.v, color.v, color.v)
	gradient_selector.set_brightness(color.v)
	base_color = color
	notify_property_manager()

func notify_property_manager():
	var color = color_manager.get_value()
	property_node.get_node("Color/Button").modulate = color
	property_node.update_value(color)
