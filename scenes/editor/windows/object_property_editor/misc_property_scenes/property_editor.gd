class_name PropertyEditor
extends HBoxContainer

const NAME_TEXT: String = "%s: "

var editor: Editor
var objects: Dictionary
var property: Array

func load_property(_editor: Editor, _objects: Dictionary, _property: Array):
	editor = _editor
	objects = _objects
	property = _property
	var property_id: String = property[0]
	
	get_node("%PropertyName").text = NAME_TEXT % property_id.capitalize()
	
	var property_info = property[2]
	if property_info is PropertyInfo:
		hint_tooltip = property_info.hint
	
	property_changed(property_id, _objects.keys()[0][property_id])
	
	for object in _objects:
		object.connect("property_changed", self, "property_changed")

func property_changed(key: String, new_value):
	if key != property[0]: return

func change_property(new_value):
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = setup_affected_objects(new_value)
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)

func setup_affected_objects(new_value) -> Dictionary:
	var affected_objects: Dictionary
	var property_id: String = property[0]
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				property_id: new_value
			},
			"original_properties": {}
		}
	return affected_objects
