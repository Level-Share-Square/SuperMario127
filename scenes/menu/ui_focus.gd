extends Control


signal back_press

export var disabled: bool

export var default_focus_path: NodePath
onready var default_focus: Button = get_node_or_null(default_focus_path)


func _input(event):
	if disabled: return
	if not is_visible_in_tree(): return
	
	if get_focus_owner() is LineEdit or get_focus_owner() is TextEdit: return
	if get_focus_owner() != null and event is InputEventMouseMotion and !Input.is_mouse_button_pressed(1): 
		get_focus_owner().release_focus()


func _unhandled_input(event):
	if not is_visible_in_tree(): return

	if event.is_action_pressed("ui_cancel"):
		if not (get_focus_owner() is LineEdit or get_focus_owner() is TextEdit): 
			emit_signal("back_press")
	
	if disabled: return
	if not is_instance_valid(default_focus): return
	
	if not is_instance_valid(get_focus_owner()):
		if (event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		or event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")):
			# we don't want the cursor to move immediately after grabbing focus
			yield(get_tree(), "idle_frame")
			default_focus.grab_focus()


func set_default_focus(node_path: String):
	default_focus = get_node_or_null(node_path)


func focus_node(node_path: String = ""):
	if LastInputDevice.is_mouse: return
	
	var node: Control = default_focus
	if node_path != "":
		node = get_node(node_path)
	
	if is_instance_valid(node):
		node.grab_focus()
