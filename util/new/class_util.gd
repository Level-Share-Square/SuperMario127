extends Node
class_name class_util

static func get_custom_class_name(instance: Object) -> String:
	var script = instance.get_script()
	if not script:
		return ""
		
	var script_path = script.resource_path
	var global_classes = ProjectSettings.get_setting("_global_script_classes")
	
	for c in global_classes:
		if c["path"] == script_path:
			return c["class"]
			
	return ""
	
static func create_instance_from_name(class_name_str: String) -> Resource:
	var global_classes = ProjectSettings.get_setting("_global_script_classes")
	
	for c in global_classes:
		if c["class"] == class_name_str:
			return load(c["path"]).new() 
			
	push_error("Could not find class: " + class_name_str)
	return null
