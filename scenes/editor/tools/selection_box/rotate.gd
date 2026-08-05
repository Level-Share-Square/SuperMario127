class_name RotateSelection
extends SelectionTool

enum Mode {LOCAL, GLOBAL}

onready var pivot = $"%Pivot"

var mode: int
var action
var init_positions: Dictionary
var init_rotations: Dictionary

func clicked():
	init_positions.clear()
	init_rotations.clear()
	mode = int(pivot.pivot_toggle.pressed)
	
	action = ChangePropertyBulkAction.new()
	action.affected_objects = setup_affected_objects()
	action.bulk_store_original_properties()

func update():
	for i in editor.selected_objects:
		_rotate(i)

func _rotate(object: GameObject):
	var mouse_pos: Vector2 = get_mouse_pos()
	match mode:
		Mode.GLOBAL:
			var init_pos: Vector2 = init_positions.get_or_add(object, object.global_position)
			var init_rot: float = init_rotations.get_or_add(object, object.rotation)
			
			var mouse_angle: float = (mouse_pos - pivot.rect_global_position).angle() - PI/2
			
			object.rotation = init_rot + mouse_angle
			object.global_position = pivot.rect_global_position + (init_pos - pivot.rect_global_position).rotated(mouse_angle)
			
			if editor.pixel_lock:
				object.rotation = stepify(object.rotation, deg2rad(15))
				object.global_position = object.global_position.snapped(Vector2(8, 8))
	
			selection_box.fit_to_bounding_rectangle()
		Mode.LOCAL:
			var angle: float = (mouse_pos - pivot.get_position_centered()).angle() - PI/2
			object.rotation = angle
			if editor.pixel_lock:
				object.rotation = stepify(object.rotation, deg2rad(15))
			
			selection_box.fit_to_bounding_rectangle()
		
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
