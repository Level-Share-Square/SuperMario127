extends WindowDialog

onready var scripting = get_parent()
onready var camera = $"../PanningCamera2D"
onready var value = get_node("Value")
onready var variable = $Var
var text_change = false
var can_drag

# Called when the node enters the scene tree for the first time.
func _ready():
	get_close_button().visible = false
	visible = true
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	value.connect("text_changed", self, "_on_Value_text_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.




func _on_Value_text_changed(new_text):
	scripting.edit_add_variable(variable.text, value.text)

func _input(event: InputEvent) -> void:
	if can_drag == true:
		if event is InputEventMouseMotion:
			if event.button_mask == BUTTON_LEFT:
				rect_position += event.relative * camera.zoom

func _on_mouse_entered():
	can_drag = true
	camera.can_drag = false
func _on_mouse_exited():
	can_drag = false
	camera.can_drag = true
