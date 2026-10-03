extends EditorTool

var last_mouse_tile: Vector2

func erase_object(object: GameObject):	
	var action := EraseObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object = object
	editor.action_manager.commit_action([action])
