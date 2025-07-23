class_name MoveSelection
extends SelectionTool


var pivot_offset: Vector2
var object_offsets: Dictionary = {}
var new_position: float
var action: ChangePropertyBulkAction


func _input(event):
	if is_active:
		selection_box.pivot_position = get_global_mouse_position() + pivot_offset
		for object in editor.selected_objects:
			object.global_position = (get_global_mouse_position() + object_offsets[object]).snapped(Vector2(8, 8)) if editor.pixel_lock else get_global_mouse_position() + object_offsets[object]
		selection_box.snap_to_selected_size()


func clicked():
	pivot_offset = selection_box.pivot_position - get_global_mouse_position()
	for object in editor.selected_objects:
		object_offsets[object] = object.global_position - get_global_mouse_position()
	
	action = ChangePropertyBulkAction.new()
	action.affected_objects = setup_affected_objects()
	action.bulk_store_original_properties()


func commit_to_action():
	for object in editor.selected_objects:
		action.affected_objects[object]["changed_properties"]["position"] = object.position
	editor.action_manager.commit_action(action)
	action = null


## for the bulk action
func setup_affected_objects() -> Dictionary:
	var affected_objects: Dictionary
	for object in editor.selected_objects:
		affected_objects[object] = {
			"changed_properties": {
				"position": object.position
			},
			"original_properties": {}
		}
	return affected_objects
