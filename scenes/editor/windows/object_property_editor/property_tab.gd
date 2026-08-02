class_name PropertyTab
extends PanelContainer

var editor: Editor
var objects: Dictionary

export var affected_properties: PoolStringArray

func change_property(property: String, new_value, check_matches):
	var affected_objects: Dictionary = setup_affected_objects(property, new_value)
	if check_matches and affected_objects["property_matches"] >= objects.size(): return
	affected_objects.erase("property_matches")
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = affected_objects
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)


func setup_affected_objects(property: String, new_value) -> Dictionary:
	var affected_objects: Dictionary = {"property_matches": 0}
	var property_id: String = property
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				property_id: new_value
			},
			"original_properties": {}
		}
		if object[property_id] == new_value:
			affected_objects["property_matches"] += 1
	return affected_objects

func get_property_value(object, property_id: String):
	if !object[property_id] is Curve2D:
		return object[property_id]
	else:
		return [object, LevelCodeSerializer.serialize_data(object[property_id])]

func connect_signals(property_editor: PropertyEditor):
	property_editor.connect("property_edited", self, "change_property")
	for object in objects:
		object.connect("property_changed", property_editor, "property_changed")
