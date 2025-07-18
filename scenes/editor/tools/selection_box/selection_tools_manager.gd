extends Control


var active_tool = "None"
onready var move = $"%Move"
onready var rotate = $"%Rotate"
onready var delete = $"%Delete"

onready var move_button = $"%MoveButton"
onready var rotate_button = $"%RotateButton"
onready var pivot_toggle_button = $"%PivotToggleButton"
onready var properties_button = $"%PropertiesButton"
onready var delete_button = $"%DeleteButton"
onready var button_container = $"../EditSelection/ButtonContainer"

onready var editor = get_tree().get_current_scene()
onready var selection_box = editor.get_node("%SelectionBox")


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in button_container.get_children():
		i.connect("button_down", self, "_on_" + i.name + "_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(active_tool)
	match active_tool:
		"Move":
			move.action()
		"Rotate":
			rotate.action()
		"Delete":
			delete.action()
		_:
			pass
			
func _on_MoveButton_pressed():
	if active_tool == "Move":
		return
	active_tool = "Move"
	move.update_mouse_anchor()
