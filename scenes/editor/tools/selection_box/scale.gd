class_name ScaleSelection
extends SelectionTool

var mode: String = "Local"
var object_offsets: Dictionary = {}
var object_scales: Dictionary = {}
var object_positions: Dictionary = {}
var action
var init_mouse: Vector2

func clicked():
	if selection_box.selection_tools.pivot_toggle_button.pressed:
		mode = "Global"
		selection_box.pivot.rect_position = Vector2(selection_box.rect_size.x/2, selection_box.rect_size.y/2)
	else:
		mode = "Local"
	init_mouse = get_global_mouse_position()
	
	
	action = ChangePropertyBulkAction.new()
	action.affected_objects = setup_affected_objects()
	action.bulk_store_original_properties()

	for object in editor.selected_objects:
		object_offsets[object] = object.global_position - selection_box.pivot_position
		object_positions[object] = object.global_position
		object_scales[object] = object.scale

func update():
	var scale_factor = (get_global_mouse_position() - init_mouse)/70.0
	if selection_box.pivot.pressed:
		_get_pivot_offset()
	if mode == "Local":
		for object in editor.selected_objects:
			object.scale = object_scales[object] + scale_factor
	elif mode == "Global":
		for object in editor.selected_objects:
			print(object_offsets[object])
			var scaled_offset = object_offsets[object] * scale_factor
			object.global_position = object_offsets[object] + (selection_box.pivot_position + scaled_offset)
			object.scale = object_scales[object] + scale_factor
			selection_box.snap_to_selected_size()
			pass
		
func _get_pivot_offset():
	if mode == "Local":
		selection_box.pivot.center_pivot()
	for object in editor.selected_objects:
		object_offsets[object] = object.global_position - selection_box.pivot.rect_global_position
		object_positions[object] = object.global_position
		object_scales[object] = object.scale
		
func commit_to_action():
	for object in editor.selected_objects:
		action.affected_objects[object]["changed_properties"]["position"] = object.position
		action.affected_objects[object]["changed_properties"]["scale"] = object.scale
	editor.action_manager.commit_action(action)
	action = null

func setup_affected_objects() -> Dictionary:
	var affected_objects: Dictionary
	for object in editor.selected_objects:
		affected_objects[object] = {
			"changed_properties": {
				"scale": object.scale,
				"position": object.position,
			},
			"original_properties": {}
		}
	return affected_objects
