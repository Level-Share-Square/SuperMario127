extends Control

var new_operation
var use_n_o = false
var variable_display = -1
var mouse_pos
onready var camera = get_node("Camera2D")
export var window : NodePath
onready var window_node = get_node(window)
const var_name_popup = preload("res://scenes/editor/window/VarNameWindow.tscn")
const new_var = preload("res://scenes/editor/scripting/newvar.tscn")
var variables : Dictionary = {}

func _process(_delta):
		
	if Input.is_action_just_pressed("RMB"):
		if window_node.visible:
			window_node.close()
			window_node.rect_position = get_global_mouse_position()
		else:
			window_node.rect_position = get_global_mouse_position()
			window_node.open()
	if window_node.newvar.pressed == true:
		new_operation = instance(var_name_popup)
		new_operation.open()
		use_n_o = true
	if use_n_o == true:
		if new_operation.save_button.pressed == true:
			variable_display += 1
			edit_add_variable(new_operation.variable_name.text, null)
			new_operation.close()
			new_operation = instance(new_var)
			use_n_o = false
			var variable_list = variables.keys()
			new_operation.variable.text = variable_list[variable_display]
func instance(filepath):
	var temp = filepath.instance()
	add_child(temp)
	return temp

func edit_add_variable(variable, value):
	variables[str(variable)] = value
		
