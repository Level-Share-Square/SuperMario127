extends TextureButton

#the previous and next nodes in the path
var first : bool
var ui

func _ready():
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
	if mouse_pos.x > position.x and mouse_pos.x < position.x + 48 and mouse_pos.y > position.y and mouse_pos.y < position.y + 48:
		print("true")
		Control.get_focus()

func _on_PathNode_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			pass
		elif event.pressed and event.button_index == BUTTON_RIGHT:
			delete()
