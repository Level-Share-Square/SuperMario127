class_name SelectionToolButton
extends ButtonSound

export var associated_tool_path: NodePath
onready var associated_tool: SelectionTool = get_node(associated_tool_path)

var seen_tooltips: Array

# what might be the worst code ive ever written
func _process(delta):
	if get_child_count() > 0:
		for child in get_children():
			if "TooltipPanel" in str(child.get_class()):
				if child in seen_tooltips: continue
				if seen_tooltips and seen_tooltips[0] != child: seen_tooltips.clear()
				seen_tooltips.append(child)
				
				child.set_as_toplevel(true)
				child.rect_global_position = get_global_mouse_position()
