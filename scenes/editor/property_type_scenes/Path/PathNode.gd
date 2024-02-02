extends TextureButton

#the previous and next nodes in the path
var first : bool
var ui
var hovered : bool = false

onready var left_handle = $HandleL
onready var right_handle = $HandleR

func _ready():
	print(rect_rotation)
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	pass

func delete():
	if !first:
		queue_free()
		ui.get_ref().node_deleted()

func _process(delta):
	pass

func is_hovered():
	var mouse_pos = get_global_mouse_position()
	var position = $rect_global_position

func _on_PathNode_gui_input(event):
	if event is InputEventMouseButton:
		ui.get_ref()._click_buffer = 0
		if event.pressed and event.button_index == BUTTON_LEFT:
			grab_focus()
		elif event.pressed and event.button_index == BUTTON_RIGHT:
			delete()

func _on_mouse_entered():
	hovered = true
	
func _on_mouse_exited():
	hovered = false

func _on_focus_entered():
	ui.get_ref().selected_node = self
	ui.get_ref().current_mode = 1
	left_handle.show()
	right_handle.show()

func _on_focus_exited():
	ui.get_ref().selected_node = null
	ui.get_ref().current_mode = 0
	left_handle.hide()
	right_handle.hide()
