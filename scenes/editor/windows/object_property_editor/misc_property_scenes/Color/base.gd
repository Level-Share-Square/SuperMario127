extends PropertyEditor

func _ready():
	var wheel = $"%Wheel"
	wheel.connect("updated", self, "_on_wheel_updated")
	
func _on_wheel_updated(color: Color):
	var color_panel = $"%Color"
	color_panel.get_stylebox("panel").bg_color = color

func load_property(_editor: Editor, _objects: Dictionary, _property: Array):
	.load_property(_editor, _objects, _property)
	var color = property[2]
	var color_panel = $"%Color"
	color_panel.get_stylebox("panel").bg_color = color #replace this with the actual color once luci fixes it
	

func property_changed(key: String, new_value):
	if key != property[0]: return
	if not new_value is Color: return
	var color_panel = $"%Color"
	var stylebox: StyleBox = color_panel.get_stylebox("Panel")

	if not stylebox is StyleBoxFlat: return
	stylebox.bg_color = new_value

