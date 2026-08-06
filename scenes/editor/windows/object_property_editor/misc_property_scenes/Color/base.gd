extends PropertyEditor

onready var expand_button = $"%ExpandButton"
onready var color_manager = $"%Expanded"
	
func update_color(color: Color, save: bool = false):
	var color_panel = $"%Color"
	color_panel.get_stylebox("panel").bg_color = color
	if save and property:
		change_property(color)
	

func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	.load_property(_editor, init_value, _property, property_name)
	var color = init_value
	var color_panel = $"%Color"
	color_panel.add_stylebox_override("panel", color_panel.get_stylebox("panel").duplicate(true))
	color_panel.get_stylebox("panel").bg_color = init_value
	
	#idk man
	var manager = $"%Expanded"
	manager.color = init_value
	

func property_changed(key: String, new_value):
	if key != property[0]: return
	if not new_value is Color: return
	var color_panel = $"%Color"
	var stylebox: StyleBox = color_panel.get_stylebox("Panel")

	if not stylebox is StyleBoxFlat: return
	stylebox.bg_color = new_value
	color_manager.update_nodes()

