extends EditorTool

var last_mouse_tile: Vector2


func _click_left(event: InputEvent, _world_pos: Vector2) -> void:
	editor.get_hovered_objects()
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		for object in editor.hovered_objects.values():
			erase_object(object)
			break


func _mouse_movement(_event: InputEvent, _world_pos: Vector2) -> void:
	editor.get_hovered_objects()
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		for object in editor.hovered_objects.values():
			erase_object(object)

func erase_object(object: GameObject):	
	var action := EraseObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object = object
	editor.action_manager.commit_action(action)
