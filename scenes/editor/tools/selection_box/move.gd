class_name MoveSelection
extends SelectionTool

var object_offsets = {}

var is_active = false
var new_position: float

# Called when the node enters the scene tree for the first time.
func _ready():
	update_mouse_anchor()



func action():
	is_active = true

func _input(event):
	if is_active == true:
		for i in editor.selected_objects:
			i.global_position = get_global_mouse_position() + object_offsets[i]
		selection_box.snap_to_selected_size()
		if Input.is_action_just_pressed("LMB"):
			

func update_mouse_anchor():
	for i in editor.selected_objects:
		object_offsets[i] = i.global_position - get_global_mouse_position()
