extends Node2D

#the previous and next nodes in the path
var first : bool
var ui
var selected : bool = false
var held : bool = false

var right_handle_active: bool = false setget set_right_handle
var left_handle_active: bool = false setget set_left_handle

## Used to check if ANY handles are active
## When set true, if neither handles are activated, then both are set active.
var handles_active: bool = false setget set_handles_active

onready var left_handle = $HandleL
onready var right_handle = $HandleR

func _ready():
	deactivate_handles()

func delete():
	if !first:
		queue_free()
		ui.get_ref().node_deleted()

func _process(delta):
	pass

func select():
	selected = true
	ui.get_ref().selected_node = self
	ui.get_ref().current_mode = 1
	if left_handle_active:
		left_handle.show()
	if right_handle_active:
		right_handle.show()

func deselect():
	ui.get_ref().selected_node = null
	ui.get_ref().current_mode = 0
	left_handle.hide()
	right_handle.hide()

func activate_all_handles():
	handles_active = true

func deactivate_handles():
	handles_active = false

func enable_left_handle():
	left_handle_active = true
	left_handle.show()

func enable_right_handle():
	right_handle_active = true
	right_handle.show()

func _on_PathNodeButton_gui_input(event):
	if event is InputEventMouseButton:
		ui.get_ref()._click_buffer = 0
		if event.pressed and event.button_index == BUTTON_LEFT:
			if !handles_active && Input.is_action_pressed("modkey"):
				activate_all_handles()
			held = true
			select()
		elif !event.pressed && event.button_index == BUTTON_LEFT:
			held = false
		elif event.pressed and event.button_index == BUTTON_RIGHT:
			if handles_active && Input.is_action_pressed("modkey"):
				deactivate_handles()
				return
			delete()
	if held && event is InputEventMouseMotion:
		position = ui.get_ref().path_node_container.get_global_transform().xform_inv(ui.get_ref().editor.get_global_mouse_position())
		ui.get_ref().update_node_position(self)

func _on_left_handle_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			pass

func set_handles_active(value):
	if value != (left_handle_active || right_handle_active):
		left_handle_active = value
		right_handle_active = value
	handles_active = value

func set_right_handle(value):
	right_handle_active = value
	if value == false:
		right_handle.hide()

func set_left_handle(value):
	left_handle_active = value
	if value == false:
		left_handle.hide()
