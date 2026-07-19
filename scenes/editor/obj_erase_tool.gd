extends EditorTool

var last_mouse_tile: Vector2


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if Input.is_action_just_pressed("LMB"):
		for object in editor.hovered_objects.values():
			erase_object(object)
			break


func _mouse_movement(_event: InputEvent, _world_pos: Vector2) -> void:
	if Input.is_action_pressed("LMB"):
		for object in editor.hovered_objects.values():
			erase_object(object)

func erase_object(object: GameObject):
	editor.object_unhovered(object)
	
	var action := EraseObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object = object
	editor.action_manager.commit_action(action)
