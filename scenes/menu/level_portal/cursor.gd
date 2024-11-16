extends Panel


func reset_cursor():
	cursor_pos = Vector2(768/2, 432/2)


func _ready():
	LastInputDevice.connect("mouse_changed", self, "mouse_changed")
	mouse_changed(false)


func mouse_changed(is_mouse: bool):
	visible = not is_mouse
	if not get_owner().is_visible_in_tree(): return
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN if not is_mouse else Input.MOUSE_MODE_VISIBLE


func _input(event):
	if not is_visible_in_tree(): return
	
	if get_focus_owner() is LineEdit: 
		if event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			get_focus_owner().release_focus()
			grab_focus()
		else:
			return

	if get_focus_owner() != self:
		if is_instance_valid(get_focus_owner()):
			get_focus_owner().release_focus()
		grab_focus()
	
	if event.is_action("ui_accept"):
		var click_event := InputEventMouseButton.new()
		click_event.device = -1
		click_event.position = get_event_pos()
		click_event.button_index = BUTTON_LEFT
		click_event.pressed = event.is_pressed()
		Input.parse_input_event(click_event)


var cursor_pos: Vector2
export var cursor_speed: float

func _process(delta):
	if get_focus_owner() != self: return
	
	var diff: Vector2 = Input.get_vector(
		"ui_left", 
		"ui_right",
		"ui_up",
		"ui_down"
	) * cursor_speed
	if not diff.is_zero_approx():
		cursor_pos += diff
		cursor_pos.x = clamp(cursor_pos.x, 0, 768)
		cursor_pos.y = clamp(cursor_pos.y, 0, 432)
		
		var event := InputEventMouseMotion.new()
		event.device = -1 # Signals this is a simulated event
		event.position = get_event_pos()
		Input.parse_input_event(event)
	
	rect_position = cursor_pos


func get_event_pos() -> Vector2:
	# positions need 2 be scaled to the root viewport first 
	# before being passed to an input event
	var transform: Transform2D = get_viewport_transform()
	return cursor_pos * transform.get_scale()
