extends Node

onready var editor = owner
onready var shared = $"%LevelShared"
onready var object_selection = $"%ObjectSelection"

func rotate_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		object_selection.selection_tools.call_deferred("start_tool_hotkey", "rotate_object")
		return
	object_selection.external_objects_selected(hovered_objects.values())
	object_selection.selection_tools.call_deferred("start_tool_hotkey", "rotate_object")


func scale_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		object_selection.selection_tools.call_deferred("start_tool_hotkey", "scale_object")
		return
	object_selection.external_objects_selected(hovered_objects.values())
	object_selection.selection_tools.call_deferred("start_tool_hotkey", "scale_object")



func flip_objects(multiplier: Vector2, objects: Array): # Hello everybody my name is
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = setup_flipped_objects(multiplier, objects)
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)

func setup_flipped_objects(multiplier: Vector2, objects) -> Dictionary:
	var affected_objects: Dictionary
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				"scale": object.scale * multiplier
			},
			"original_properties": {}
		}
	return affected_objects
	
func disable_objects(objects: Array): # Hello everybody my name is
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = setup_disabled_objects(objects)
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)

func setup_disabled_objects(objects) -> Dictionary:
	var affected_objects: Dictionary
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				"enabled": !object.enabled
			},
			"original_properties": {}
		}
	return affected_objects


func mirror_h():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		flip_objects(Vector2(-1, 1), editor.selected_objects)
		return
	flip_objects(Vector2(-1, 1), hovered_objects.values())


func mirror_v():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		flip_objects(Vector2(1, -1), editor.selected_objects)
		return
	flip_objects(Vector2(1, -1), hovered_objects.values())


func disable_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !(editor.get_hovered_objects() or editor.selected_objects): return
	
	if editor.selected_objects:
		disable_objects(editor.selected_objects)
		return
	disable_objects(hovered_objects.values())
