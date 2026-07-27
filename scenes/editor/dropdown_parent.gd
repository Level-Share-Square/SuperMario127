extends Control

onready var parent: Control = get_parent()
onready var dropdown: Control = get_child(0)

func _ready() -> void:
	parent.connect("resized", self, "dropdown_resized")
	dropdown.connect("resized", self, "dropdown_resized")
	dropdown_resized()

func dropdown_resized() -> void:
	rect_min_size.x = max(dropdown.rect_size.x, parent.rect_size.x)
	dropdown.rect_size.x = rect_min_size.x
	print("resized")
