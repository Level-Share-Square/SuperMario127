extends EditorWindow


const TITLE_TEXT: String = "%s Properties"

onready var window_title = $"%WindowTitle"
onready var window_icon = $"%WindowIcon"
onready var property_groups = $"%PropertyGroups"

var objects: Dictionary
var common_properties: Array
var common_property_tabs: Array
var property_tallies: Dictionary


func load_objects(_objects: Dictionary):
	objects = _objects
	
	common_properties = []
	common_property_tabs = []
	property_tallies = {}
	for child in property_groups.get_children():
		child.queue_free()
	
	yield(get_tree(), "idle_frame")
	
	var base_tab: PropertyTab = preload(
		"res://scenes/editor/windows/object_property_editor/property_tabs/base/base.tscn"
	).instance()
	property_groups.add_child(base_tab)
	
	for _game_object in objects.keys():
		var game_object: GameObject = _game_object
		var item: PlaceableItem = objects[game_object]
		
		window_title.text = TITLE_TEXT % item.item_name
		window_icon.texture = item.icons[item.palette]
		
		var index: int = 0
		for _property in game_object.editable_properties:
			var property: Array = [
				_property, 
				typeof(game_object[_property]), 
				str(game_object.property_hints[index])
			]
			if not property in common_properties:
				common_properties.append(property)
				property_tallies[property] = 0
			property_tallies[property] += 1
			index += 1
	
	for property in common_properties.duplicate():
		if property_tallies[property] < objects.size():
			common_properties.erase(property)
	
	if common_properties.size() > 0:
		var misc_tab: PropertyTab = preload(
			"res://scenes/editor/windows/object_property_editor/property_tabs/misc/misc.tscn"
		).instance()
		misc_tab.load_misc_properties(common_properties)
		property_groups.add_child(misc_tab)
		property_groups.move_child(misc_tab, 0)
	
	popup_centered(rect_size)
