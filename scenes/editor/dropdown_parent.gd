extends Control

onready var editor: Editor = owner
onready var parent: Control = get_parent()
onready var dropdown: Control = get_child(0)
onready var layer_dropdown = $"%LayerDropdown"

func _ready() -> void:
	parent.connect("resized", self, "dropdown_resized")
	dropdown.connect("resized", self, "dropdown_resized")
	dropdown_resized()
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "dropdown_resized")
	editor.action_manager.connect("redo", self, "dropdown_resized")
	editor.action_manager.connect("action", self, "dropdown_resized")

func dropdown_resized() -> void:
	rect_min_size.x = max(dropdown.rect_size.x, parent.rect_size.x)
	rect_size.x = rect_min_size.x
	dropdown.rect_size.x = max(dropdown.rect_size.x, rect_min_size.x)
