extends PropertyEditor


func property_changed(key: String, new_value):
	if key != property[0]: return
	if not new_value is Color: return

	var color_panel: Panel = $"%Color"
	var stylebox: StyleBox = color_panel.get_stylebox("Panel")

	if not stylebox is StyleBoxFlat: return
	stylebox.bg_color = new_value
