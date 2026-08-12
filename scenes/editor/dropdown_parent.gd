extends Control

onready var editor: Editor = owner
onready var parent: Control = get_parent()
onready var dropdown: Control = get_child(0)
onready var layer_dropdown = $"%LayerDropdown"
var resizing: bool = false

func _ready() -> void:
	parent.connect("resized", self, "dropdown_resized")
	dropdown.connect("resized", self, "dropdown_resized")
	dropdown_resized()
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "dropdown_resized")
	editor.action_manager.connect("redo", self, "dropdown_resized")
	editor.action_manager.connect("action", self, "dropdown_resized")

func dropdown_resized() -> void:
	if resizing: return
	resizing = true
	var dropdown_min: float = dropdown.get_minimum_size().x
	hide()
	rect_min_size.x = max(dropdown_min, parent.get_minimum_size().x)
	rect_size.x = rect_min_size.x
	dropdown.rect_size.x = rect_min_size.x
	show()
	resizing = false
