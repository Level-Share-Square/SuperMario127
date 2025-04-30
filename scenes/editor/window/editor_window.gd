extends Popup


export(NodePath) var window_panel_path
export(NodePath) var drag_control_path
export(NodePath) var close_button_path

export var window_size: Vector2

var drag_position: Vector2


func _ready() -> void:
	var window_panel: PanelContainer = get_node(window_panel_path)
	rect_min_size = window_panel.get_minimum_size()
	
	var drag_control: Control = get_node(drag_control_path)
	drag_control.connect("gui_input", self, "drag_window")
	
	var close_button: BaseButton = get_node(close_button_path)
	close_button.connect("pressed", self, "hide")
	
	window_size.x = max(rect_min_size.x, window_size.x)
	window_size.y = max(rect_min_size.y, window_size.y)
	
	popup_centered(window_size)


func drag_window(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_local_mouse_position()
			raise()
	if (event is InputEventMouseMotion) and (event.button_mask == BUTTON_LEFT):
		rect_global_position = event.global_position - drag_position
