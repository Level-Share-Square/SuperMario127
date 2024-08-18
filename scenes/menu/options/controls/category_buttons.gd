extends HBoxContainer

signal category_switched(category_name)

export var default_theme: String
export var selected_theme: String

export var remapper_path: NodePath
onready var remapper: Control = get_node(remapper_path)

func switch_category(category_name: String):
	for child in remapper.get_children():
		child.visible = (child.name == category_name)
		if child.visible:
			remapper.current_category = child
	
	for button in get_children():
		if button is Button:
			button.theme_type_variation = default_theme
			if (button.name == category_name):
				button.theme_type_variation = selected_theme
	
	emit_signal("category_switched", category_name)
