extends Control

export var disabled: bool

export var default_focus_path: NodePath
onready var default_focus: Button = get_node(default_focus_path)

func _input(event):
	if disabled: return
	if not get_parent().visible: return
	
	if get_focus_owner() != null and event is InputEventMouseMotion and !Input.is_mouse_button_pressed(1): 
		get_focus_owner().release_focus()

func _unhandled_input(event):
	if disabled: return
	if not get_parent().visible: return
	if not is_instance_valid(default_focus): return
	
	if get_focus_owner() == null:
		if (event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		or event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")):
			# we don't want the cursor to move immediately after grabbing focus
			yield(get_tree(), "idle_frame")
			default_focus.grab_focus()
