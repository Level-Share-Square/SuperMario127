extends Node2D


enum {HANDLE_RIGHT, HANDLE_LEFT}

#the previous and next nodes in the path
var first : bool
var ui
var selected : bool = false
var held : bool = false

var right_handle_enabled: bool = false setget set_right_handle_enabled
var left_handle_enabled: bool = false setget set_left_handle_enabled
var left_handle_held: bool = false
var right_handle_held: bool = false
## Used to check if ANY handles are active
## When set true, if neither handles are activated, then both are set active.
var handles_active: bool = false setget set_handles_active
## If true, both handles will act as one 
## (vectors will be equal and inverse to each other)
var handles_linked: bool

onready var left_handle: Node2D = $HandleL
onready var right_handle: Node2D = $HandleR
onready var handle_positions_before_link: PoolVector2Array = [left_handle.position, right_handle.position]

func _ready():
	set_handles_active(false)

func delete():
	if !first:
		ui.get_ref().delete_node(self)
		queue_free()

func _process(delta):
	if check_if_hovered():
		ui.get_ref().last_hovered_node = self

func select():
	selected = true
	ui.get_ref().selected_node = self
	ui.get_ref().current_mode = 1
	if left_handle_enabled:
		left_handle.show()
	if right_handle_enabled:
		right_handle.show()

func deselect():
	ui.get_ref().selected_node = null
	ui.get_ref().current_mode = 0
	left_handle.hide()
	right_handle.hide()


func _on_PathNodeButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if Input.is_action_pressed("path_editor_modkey"):
				if handles_active:
					_toggle_handle_link()
				else:
					set_handles_active(true)
			held = true
			select()
		elif !event.pressed && event.button_index == BUTTON_LEFT:
			held = false
		elif event.pressed and event.button_index == BUTTON_RIGHT:
			if handles_active && Input.is_action_pressed("path_editor_modkey"):
				set_handles_active(false)
				return
			delete()
	if held && event is InputEventMouseMotion:
		position = ui.get_ref().path_node_container.get_global_transform().xform_inv(ui.get_ref().editor.get_global_mouse_position())
		if !Input.is_action_pressed("path_editor_snap"):
			position = position.snapped(Vector2(8, 8))
		ui.get_ref().update_node_position(self)

func _on_left_handle_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			left_handle_held = true
			select()
		elif !event.pressed && event.button_index == BUTTON_LEFT:
			left_handle_held = false
	if left_handle_held && event is InputEventMouseMotion:
		move_handle(HANDLE_LEFT, ui.get_ref().path_node_container.get_global_transform().xform_inv(ui.get_ref().editor.get_global_mouse_position()) - position, true)


func _on_right_handle_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			right_handle_held = true
			select()
		elif !event.pressed && event.button_index == BUTTON_LEFT:
			right_handle_held = false
	if right_handle_held && event is InputEventMouseMotion:
		move_handle(HANDLE_RIGHT, ui.get_ref().path_node_container.get_global_transform().xform_inv(ui.get_ref().editor.get_global_mouse_position()) - position, true)


func move_handle(handle: int, new_pos: Vector2, moved_by_user: bool = false):
		var handle_ref = right_handle if handle == HANDLE_RIGHT else left_handle
		if moved_by_user && !Input.is_action_pressed("path_editor_snap"):
			new_pos = new_pos.snapped(Vector2(8, 8))
		handle_ref.position = new_pos
		handle_ref.get_node("Handle%sLine" % ("R" if handle == HANDLE_RIGHT else "L")).points[1] = handle_ref.to_local(global_position)
		if handles_linked:
			handle_ref = left_handle if handle == HANDLE_RIGHT else right_handle
			handle_ref.position = -new_pos
			handle_ref.get_node("Handle%sLine" % ("L" if handle == HANDLE_RIGHT else "R")).points[1] = handle_ref.to_local(global_position)
		ui.get_ref().update_node_handles(self)

func set_handles_active(value):
	set_right_handle_enabled(value)
	set_left_handle_enabled(value)
	handles_active = value

func set_right_handle_enabled(value):
	right_handle_enabled = value
	_set_handle_visible(HANDLE_RIGHT, value)
	_check_handles_active()

func set_left_handle_enabled(value):
	if first:
		value = false
	left_handle_enabled = value
	_set_handle_visible(HANDLE_LEFT, value)
	_check_handles_active()
	
func _check_handles_active():
	handles_active = true if left_handle_enabled or right_handle_enabled else false

func _set_handle_visible(handle: int, value: bool):
	match handle:
		HANDLE_LEFT:
			if value == true && left_handle_enabled:
				left_handle.show()
			else:
				left_handle.hide()
		HANDLE_RIGHT:
			if value == true && right_handle_enabled:
				right_handle.show()
			else:
				right_handle.hide()

func _toggle_handle_link():
	if !handles_linked:
		handle_positions_before_link = [left_handle.position, right_handle.position]
	handles_linked = !handles_linked
	if !handles_linked:
		move_handle(HANDLE_LEFT, handle_positions_before_link[HANDLE_LEFT])
		move_handle(HANDLE_RIGHT, handle_positions_before_link[HANDLE_RIGHT])
	else:
		move_handle(HANDLE_LEFT, Vector2(24, 0))

func check_if_hovered():
	return $PathNodeButton.is_hovered() || left_handle.get_node("HandleLButton").is_hovered() || right_handle.get_node("HandleRButton").is_hovered()
