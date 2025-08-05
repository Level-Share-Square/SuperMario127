extends TextureRect

var pressed = false

onready var selector = $"HSV Color Selector"
onready var gradient_selector = get_parent().get_node("Gradient")
onready var new_color_preview = get_parent().get_node("ColorPreviews/NewColorPreview")
onready var color_manager = $Color
onready var r = $"%R"
onready var g = $"%G"
onready var b = $"%B"
onready var a = $"%A"

var property_node : Node
var base_color : Color # color without transparency

signal updated(color)

func _ready():
	var colors = [r, g, b, a]
	for color in colors:
		color.connect("color_change", self, "_on_color_changed")

func _input(event):
	if get_parent().get_parent().get_parent().rect_min_size.y == 0:
		return
	
	var center = get_rect().size / 2
	var mouse_pos = get_local_mouse_position() - center
	var normal_coordinates = ((mouse_pos) / get_rect().size.x * 2)
	
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		pressed = event.pressed && normal_coordinates.length() <= 1
	
	if !pressed:
		return
	
	normal_coordinates = normal_coordinates.normalized() * min(normal_coordinates.length(), 1)
	mouse_pos = mouse_pos.normalized() * min(mouse_pos.length(), get_rect().size.x/2)
	# Is in sprite - check if its in the circle
	selector.rect_position = mouse_pos + center - Vector2(5, 5)
	base_color = Color.from_hsv((atan2(-normal_coordinates.x, -normal_coordinates.y) / (2*PI)) + 0.5, normal_coordinates.length(), gradient_selector.value)
	gradient_selector.modulate = base_color
	gradient_selector.modulate.a = 255
	emit_signal("updated", base_color)
	
func update_value(color: Color, notify_manager: bool = true):
	var length := get_rect().size.x * color.s / 2
	var angle := color.h*2*PI
	selector.rect_position = Vector2(sin(angle)*length, cos(angle)*length)
	gradient_selector.modulate = color
	gradient_selector.modulate.a = 255
	self_modulate = Color(color.v, color.v, color.v)
	gradient_selector.set_brightness(color.v)
	base_color = color
