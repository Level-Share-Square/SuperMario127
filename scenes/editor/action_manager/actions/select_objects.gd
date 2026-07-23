class_name SelectObjectsAction
extends Action


var editor: Editor
var selection_box: NinePatchRect
var selected_objects: Dictionary
var old_selected_objects: Dictionary


func select_objects(selected_dict: Dictionary):
	for object in editor.selected_objects:
		object.selected = false
	editor.selected_objects = {}
	for object in selected_dict:
		editor.selected_objects[object] = selected_dict[object]
		object.selected = true
	editor.open_object_properties(selected_dict)


func _do() -> void:
	old_selected_objects = editor.selected_objects.duplicate()
	select_objects(selected_objects)


func _undo() -> void:
	select_objects(old_selected_objects)
