extends Node2D

#the previous and next nodes in the path
var first : bool
var ui
var selected : bool = false
var held : bool = false

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

func deselect():
	ui.get_ref().selected_node = null
	ui.get_ref().current_mode = 0

func _on_PathNodeButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			held = true
			select()
		elif !event.pressed && event.button_index == BUTTON_LEFT:
			held = false
		elif event.pressed and event.button_index == BUTTON_RIGHT:
			delete()
	if held && event is InputEventMouseMotion:
		var new_position : Vector2 = ui.get_ref().point_node_container.get_global_transform().xform_inv(ui.get_ref().editor.get_global_mouse_position()).snapped(Vector2(8, 8))
		if Input.is_action_pressed("path_editor_snap"):
			new_position = position
		position = new_position

func check_if_hovered():
	return $PathNodeButton.is_hovered()
