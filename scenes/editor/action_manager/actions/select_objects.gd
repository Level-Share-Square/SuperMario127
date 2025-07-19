class_name SelectObjectsAction
extends Action


var editor: Editor
var selection_box: NinePatchRect
var selected_objects: Dictionary
var old_selected_objects: Dictionary


func select_objects(selected_dict: Dictionary):
	for object in editor.selected_objects:
		object.modulate = Color(1, 1, 1, object.modulate.a)
	editor.selected_objects = {}
	for object in selected_dict:
		editor.selected_objects[object] = selected_dict[object]
		object.modulate = Color(0.8, 0.8, 1.2, object.modulate.a)
	
	selection_box.get_parent().selected_dict = editor.selected_objects.duplicate()
	if selected_dict.empty():
		selection_box.get_parent().hide_selection_box()
	else:
		selection_box.get_parent().show_selection_box()


func _do() -> void:
	old_selected_objects = editor.selected_objects.duplicate()
	select_objects(selected_objects)


func _undo() -> void:
	select_objects(old_selected_objects)
