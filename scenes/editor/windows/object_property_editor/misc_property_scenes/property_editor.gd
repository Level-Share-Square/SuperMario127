class_name PropertyEditor
extends Control

onready var hover_sound: AudioStreamPlayer = get_parent().get_node("%HoverSound") 
onready var click_sound: AudioStreamPlayer = get_parent().get_node("%ClickSound") 
const NAME_TEXT: String = "%s: "

# check if the property actually changes before updating it
# can be toggled off because of visibility shenanigans
export var check_matches: bool = true

var editor: Editor
var property: Array

signal property_edited(property, value, check_matches, save_to_data)

func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	editor = _editor
	property = _property
	var property_id: String = property[0]
	
	get_node("%PropertyName").text = NAME_TEXT % property_id.capitalize() if !property_name else NAME_TEXT % property_name
	
	if property.size() > 2:
		var property_info = property[2]
		if property_info is PropertyInfo:
			hint_tooltip = property_info.hint
	
	property_changed(property_id, init_value)
#
#	for object in _objects:
#		object.connect("property_changed", self, "property_changed")


func _ready():
	for node in get_children():
		if "hover_sound" in node:
			node.hover_sound = hover_sound
			node.click_sound = click_sound


func property_changed(key: String, new_value):
	if key != property[0]: return


func change_property(new_value, save_to_data: bool = true):
#	var affected_objects: Dictionary = setup_affected_objects(new_value)
#	if check_matches and affected_objects["property_matches"] >= objects.size(): return
#	affected_objects.erase("property_matches")
#
#	var action := ChangePropertyBulkAction.new()
#	action.affected_objects = affected_objects
#	action.bulk_store_original_properties()
#	editor.action_manager.commit_action(action)
	emit_signal("property_edited", property[0], new_value, check_matches, save_to_data)


#func setup_affected_objects(new_value) -> Dictionary:
#	var affected_objects: Dictionary = {"property_matches": 0}
#	var property_id: String = property[0]
#	for object in objects:
#		affected_objects[object] = {
#			"changed_properties": {
#				property_id: new_value
#			},
#			"original_properties": {}
#		}
#		if object[property_id] == new_value:
#			affected_objects["property_matches"] += 1
#	return affected_objects
