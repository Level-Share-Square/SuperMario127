extends Control

var new_operation
var use_n_o = false
export var window : NodePath
onready var window_node = get_node(window)
const var_name_popup = preload("res://scenes/editor/window/VarNameWindow.tscn")
const new_var = preload("res://scenes/editor/scripting/newvar.tscn")
var variables : Dictionary = {}

func _process(_delta):
	print(variables)
	if Input.is_action_just_pressed("RMB"):
		if window_node.visible:
			window_node.close()
			window_node.rect_position = get_global_mouse_position()
		else:
			window_node.rect_position = get_global_mouse_position()
			window_node.open()
	if window_node.newvar.pressed == true:
		new_operation = instance(var_name_popup)
		use_n_o = true
	if use_n_o == true:
		if new_operation.save_button.pressed == true:
			edit_add_variable(new_operation.variable_name.text, null)
			new_operation.queue_free()
			new_operation = instance(new_var)
			use_n_o = false
			new_operation.variable.text = "23"
func instance(filepath):
	var temp = filepath.instance()
	add_child(temp)
	return temp

func edit_add_variable(variable, value):
	variables[str(variable)] = value
		
