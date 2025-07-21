class_name PropertyEditorLoader
extends TabContainer


var tabs: Dictionary = {}


func load_property_editors(data: ObjectData):
	for i in range(data.properties.size()):
		create_property_editor(
			data.properties[i], 
			data.property_hints[i]
		)


func create_property_editor(
	value, 
	hints: PropertyHints
):
	var property_editor: PropertyEditor
	
	var type_path: String
	
	match typeof(value):
		TYPE_VECTOR2:
			type_path = "Vector2"
		TYPE_REAL:
			type_path = "float"
		TYPE_BOOL:
			type_path = "bool"
		TYPE_INT:
			type_path = "int"
	
	var scene: PackedScene = load("res://scenes/editor/windows/object_property_editor/property_editor_scenes/%s/" % type_path + hints.editor + "/" + hints.editor + ".tscn")
	if is_instance_valid(scene):
		property_editor = scene.instance()
		property_editor.connect("ready", property_editor, "setup", [value, hints])
		
		var property_tab = get_or_add_tab(hints.tab)
		print(property_tab)
		property_tab.add_child(property_editor)


func get_or_add_tab(tab_name: String) -> ScrollContainer:
	var tab = tabs.get(tab_name)
	
	if not is_instance_valid(tab):
		tab = ScrollContainer.new()
		tab.name = tab_name.capitalize()
		tab.scroll_horizontal = false
		
		add_child(tab)
		tabs.get_or_add(tab_name, tab)
	
	return tab
