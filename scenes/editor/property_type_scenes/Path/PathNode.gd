extends Node2D

#the previous and next nodes in the path
var first : bool
var ui
var selected : bool = false
var held : bool = false

var handles_active: bool = false

onready var left_handle = $HandleL
onready var right_handle = $HandleR

func _ready():
	pass

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
	if handles_active:
		left_handle.show()
		right_handle.show()

func deselect():
	ui.get_ref().selected_node = null
	ui.get_ref().current_mode = 0
	left_handle.hide()
	right_handle.hide()

func activate_handles():
	handles_active = true

func deactivate_handles():
	handles_active = false
	left_handle.hide()
	right_handle.hide()

func _on_PathNodeButton_gui_input(event):
	if event is InputEventMouseButton:
		ui.get_ref()._click_buffer = 0
		if event.pressed and event.button_index == BUTTON_LEFT:
			if !handles_active && Input.is_action_pressed("modkey"):
				activate_handles()
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
		global_position += event.relative
		ui.get_ref().update_node_position(self)
