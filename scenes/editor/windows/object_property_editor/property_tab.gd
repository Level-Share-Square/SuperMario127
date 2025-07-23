class_name PropertyTab
extends ScrollContainer


const subgroup_pointers: Array = ["Buttons", "Lines", "Dialogue", "Warp"]

onready var subgroups = $"%Subgroups"


func add_editor(editor: PropertyEditor) -> void:
	var subgroup = get_node("%" + subgroup_pointers[editor.subgroup])
	subgroup.add_child(editor)
	
	if subgroup.get_child_count() > 0:
		subgroup.show()
		
		# my hacky method of getting the horizontal separators to show up :D
		var child_index = subgroup.get_index()
		subgroups.get_child(child_index + 1).visible = true
