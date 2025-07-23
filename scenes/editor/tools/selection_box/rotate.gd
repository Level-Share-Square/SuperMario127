class_name RotateSelection
extends SelectionTool

var mode: String = "Global"
var object_offsets: Dictionary = {}
var object_rotations: Dictionary = {}
var action
var base_rotation = 0
var mouse_pivot_base_angle = 0

func clicked():
	object_offsets = {}
	if selection_box.selection_tools.pivot_toggle_button.pressed:
		mode = "Global"
	else:
		mode = "Local"
	_get_pivot_offset()
	for object in editor.selected_objects:
		var pivot = selection_box.pivot_position
		object_offsets[object] = object.global_position - pivot
		

	
	action = ChangePropertyBulkAction.new()
	action.affected_objects = setup_affected_objects()
	action.bulk_store_original_properties()

func _get_pivot_offset():
	if mode == "Local":
		selection_box.pivot.center_pivot()
	mouse_pivot_base_angle = get_global_mouse_position().direction_to(selection_box.pivot.rect_global_position).angle()
	for object in editor.selected_objects:
		object_offsets[object] = object.global_position - selection_box.pivot.rect_global_position
		object_rotations[object] = object.rotation
		
func update():
	if selection_box.pivot.pressed:
		_get_pivot_offset()
	base_rotation = get_global_mouse_position().direction_to(selection_box.pivot_position).angle() - mouse_pivot_base_angle
	for i in editor.selected_objects:
		_rotate(i)

func _rotate(object: GameObject):
	var old_rotation = object_rotations[object]
	var theta: float = base_rotation
	if mode == "Global":
		var pivot = selection_box.pivot_position + selection_box.pivot.rect_pivot_offset
		var offset = object_offsets[object]

		var rotated_offset = offset.rotated(theta)

		object.global_position = pivot + rotated_offset
		object.rotation = old_rotation + theta
		if editor.pixel_lock:
			object.rotation = stepify(object.rotation, deg2rad(15))
			object.global_position = object.global_position.snapped(Vector2(8, 8))
		
		selection_box.snap_to_selected_size()
	else:
		object.rotation = old_rotation + theta
		if editor.pixel_lock:
			object.rotation = stepify(object.rotation, deg2rad(15))
		
		selection_box.snap_to_selected_size()
		
func commit_to_action():
	for object in editor.selected_objects:
		action.affected_objects[object]["changed_properties"]["position"] = object.position
		action.affected_objects[object]["changed_properties"]["rotation_degrees"] = object.rotation_degrees
	editor.action_manager.commit_action(action)
	action = null

func setup_affected_objects() -> Dictionary:
	var affected_objects: Dictionary
	for object in editor.selected_objects:
		affected_objects[object] = {
			"changed_properties": {
				"rotation_degrees": object.rotation_degrees,
				"position": object.position,
			},
			"original_properties": {}
		}
	return affected_objects
