class_name ScaleSelection
extends SelectionTool

const SCALE_DISTANCE: float = 70.0

var object_scales: Dictionary = {}
var action
var init_mouse: Vector2

func clicked():
	init_mouse = get_global_mouse_position()
	
	
	action = ChangePropertyBulkAction.new()
	action.affected_objects = setup_affected_objects()
	action.bulk_store_original_properties()

	for object in editor.selected_objects:
		object_scales[object] = object.scale

func update():
	var scale_factor = (get_global_mouse_position() - init_mouse)/SCALE_DISTANCE
	for object in editor.selected_objects:
		object.scale = object_scales[object] + scale_factor
	
		
func commit_to_action():
	for object in editor.selected_objects:
		action.affected_objects[object]["changed_properties"]["scale"] = object.scale
	editor.action_manager.commit_action(action)

func setup_affected_objects() -> Dictionary:
	var affected_objects: Dictionary
	for object in editor.selected_objects:
		affected_objects[object] = {
			"changed_properties": {
				"scale": object.scale,
			},
			"original_properties": {}
		}
	return affected_objects
