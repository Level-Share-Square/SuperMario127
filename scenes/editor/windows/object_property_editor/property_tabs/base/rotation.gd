extends PropertyEditor


func property_changed(key: String, new_value):
	if key != property[0]: return
	var line_edit: LineEdit = $"%LineEdit"
	line_edit.text = str(stepify(new_value, 0.01))

func load_property(_editor: Editor, init_value, _property: Array):
	.load_property(_editor, init_value, _property)

func change_property(new_value):
	.change_property(wrapf(new_value, 0, 360))

func done_editing(_val: String):
	change_property(float($"%LineEdit".text))

func increment_property(step: float):
	var cur_rot := float($"%LineEdit".text)
	change_property(cur_rot + step)
