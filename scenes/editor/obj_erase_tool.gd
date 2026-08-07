extends EditorTool

var last_mouse_tile: Vector2


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	editor.get_hovered_objects()
	if Input.is_action_just_pressed("click"):
		for object in editor.hovered_objects.values():
			erase_object(object)
			break


func _mouse_movement(_event: InputEvent, _world_pos: Vector2) -> void:
	editor.get_hovered_objects()
	if Input.is_action_pressed("click"):
		for object in editor.hovered_objects.values():
			erase_object(object)

func erase_object(object: GameObject):	
	var action := EraseObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object = object
	editor.action_manager.commit_action(action)
