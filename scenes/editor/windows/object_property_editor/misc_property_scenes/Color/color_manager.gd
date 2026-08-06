extends HBoxContainer

onready var wheel = $"%Wheel"
onready var color_selector = $"%ColorSelector"
onready var gradient = $"%Gradient"
onready var gradient_selector = $"%GradientSelector"
onready var slider_r = $"%SliderR"
onready var slider_g = $"%SliderG"
onready var slider_b = $"%SliderB"
onready var slider_a = $"%SliderA"
onready var slider_i = $"%SliderI"
onready var expand_button = $"%ExpandButton"
onready var hex_code = $"%HexCode"
onready var property_editor = owner

onready var sliders: Array = [slider_r, slider_g, slider_b, slider_a, slider_i]

var color: Color

var move_wheel: bool = false
var move_gradient: bool = false
var move_slider: bool = false

var intensity: float = 0

func _ready():
	for slider in sliders:
		slider.get_node("HSlider").share(slider.get_node("Spinbox"))
		slider.get_node("Spinbox").connect("value_changed", self, "component_changed", [slider.component])
		slider.get_node("Spinbox").max_value = 255 if slider.component != ColorComponents.Component.INTENSITY else 100
	hex_code.get_node("LineEdit").connect("focus_exited", self, "hex_code_entered")
	hex_code.get_node("LineEdit").connect("text_entered", self, "text_entered")
	
func _input(event):
	if !get_tree().current_scene.get_node("%ObjectSettingsWindow").visible: expand_button.active = false
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var mouse_pos: Vector2 = get_global_mouse_position()
		
		if circle_has_point(wheel.rect_global_position + wheel.rect_pivot_offset, wheel.rect_pivot_offset.x, mouse_pos) and expand_button.active:
			move_wheel = true
		if gradient.get_global_rect().has_point(mouse_pos) and expand_button.active:
			move_gradient = true
			
func circle_has_point(center: Vector2, radius: float, point: Vector2) -> bool:
	return center.distance_squared_to(point) <= (radius * radius)

func _process(delta):
	if !expand_button.active: return
	if move_wheel:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if Input.is_action_pressed("LMB"):
			if circle_has_point(wheel.rect_global_position + wheel.rect_pivot_offset, wheel.rect_pivot_offset.x, mouse_pos):
				color_selector.rect_global_position = mouse_pos - (color_selector.rect_size * color_selector.rect_scale)/2
				update_color()
				update_nodes()
		else:
			move_wheel = false
			finish_color()
			
	if move_gradient:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if Input.is_action_pressed("LMB"):
			if gradient.get_global_rect().has_point(mouse_pos):
				gradient_selector.rect_global_position.y = mouse_pos.y
				update_color()
				update_nodes()
		else:
			move_gradient = false
			finish_color()
	
	if move_slider and Input.is_action_just_released("LMB"):
		move_slider = false
		finish_color()

func update_color() -> void:
	var selector_center: Vector2 = color_selector.rect_global_position
	var wheel_center: Vector2 = wheel.rect_global_position + wheel.rect_size/2
	
	var offset: Vector2 = selector_center - wheel.get_global_rect().get_center()
	
	color.h = wrapf((atan2(-offset.x, -offset.y) / TAU) + 0.5, 0.0, 1.0)
	color.s = clamp(offset.length() / wheel.rect_pivot_offset.x, 0.0, 2.0)
	
	var white_y: float = 0
	var black_y: float = gradient.get_rect().size.y
	
	color.v = clamp((gradient_selector.rect_position.y - black_y) / (white_y - black_y), 0.0, 1.0)
	component_changed(slider_i.get_node("Spinbox").value, ColorComponents.Component.INTENSITY)
	
func update_nodes() -> void:
	for slider in sliders:
		slider.get_node("Spinbox").set_block_signals(true)
	
	wheel.self_modulate = Color(color.v, color.v, color.v)
	gradient.self_modulate = color
	slider_r.get_node("Spinbox").value = color.r * 255.0
	slider_g.get_node("Spinbox").value = color.g * 255.0
	slider_b.get_node("Spinbox").value = color.b * 255.0
	slider_a.get_node("Spinbox").value = color.a * 255.0
	hex_code.get_node("LineEdit").text = "#" + color.to_html(false)
	
	if !(move_wheel or move_gradient):
		var length: float = wheel.rect_pivot_offset.x * color.s
		var angle: float = color.h * TAU
		var local_center_pos = Vector2(sin(angle) * length, cos(angle) * length)
		color_selector.rect_position = wheel.rect_pivot_offset + local_center_pos
		
	for slider in sliders:
		slider.get_node("Spinbox").set_block_signals(false)
		
	property_editor.update_color(color, false)
	
func read_intensity():
	slider_i.get_node("Spinbox").value = max(color.r, max(color.g, color.b))
	
func component_changed(value: float, component: int):
	if !(move_wheel or move_gradient): move_slider = true
	match component:
		ColorComponents.Component.RED:
			color.r = value/255.0
		ColorComponents.Component.GREEN:
			color.g = value/255.0
		ColorComponents.Component.BLUE:
			color.b = value/255.0
		ColorComponents.Component.ALPHA:
			color.a = value/255.0
		ColorComponents.Component.INTENSITY:
			color.v = min(max(color.r, max(color.g, color.b)), 1) * value
	update_nodes()

func hex_code_entered():
	var new_code: String = hex_code.get_node("LineEdit").text
	if new_code.is_valid_hex_number():
		color = Color(new_code)
	finish_color()
	update_nodes() 

func text_entered(new_text: String):
	hex_code.get_node("LineEdit").release_focus()

func finish_color():
	property_editor.update_color(color, true)
