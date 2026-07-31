class_name SelectObjectsAction
extends Action


var editor: Editor
var selection_box: NinePatchRect
var selected_objects: Array
var old_selected_objects: Array


func select_objects(selected_array: Array):
	for object in editor.selected_objects:
		object.selected = false

	editor.selected_objects = selected_array
	for object in editor.selected_objects:
		object.selected = true

	editor.open_object_properties(selected_array)


func _do() -> void:
	old_selected_objects = editor.selected_objects.duplicate()
	select_objects(selected_objects)


func _undo() -> void:
	select_objects(old_selected_objects)
