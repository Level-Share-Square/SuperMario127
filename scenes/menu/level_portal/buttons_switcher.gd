extends MarginContainer


onready var subscreens = $"%Subscreens"


func screen_changed():
	for child in get_children():
		child.visible = false
		if child.name == subscreens.get_screen_name():
			child.visible = true
