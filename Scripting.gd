extends Control

var new_operation
var use_n_o = false
var variable_display = -1
var variable_num = 0
var mouse_pos
var mouse_offset
var selected = false
onready var camera = get_node("Camera2D")
export var window : NodePath
onready var window_node = get_node(window)
const var_name_popup = preload("res://scenes/editor/window/VarNameWindow.tscn")
const new_var = preload("res://scenes/editor/scripting/newvar.tscn")
var instances = []
var new_var_instances = []
var variables : Dictionary = {}
var index

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
		instances.append(instance(var_name_popup))
		instances[0].open()
		use_n_o = true
	if use_n_o == true:
		if instances[0].save_button.pressed == true:
			variable_display += 1
			variable_num += 1
			edit_add_variable(instances[0].variable_name.text, null)
			instances[0].close()
			instances.append(instance(new_var))
			use_n_o = false
			var variable_list = variables.keys()
			instances[variable_num].variable.text = variable_list[variable_display]
	if instances.size() > 1:
		if "NewVar" in str(instances[1]):
			if instances[1].text_change == true:
				edit_add_variable(instances[1].variable.text, instances[1].value.text)
	if instances.size() > 3:
		if "NewVar" in str(instances[3]):
			if instances[3].text_change == true:
				edit_add_variable(instances[3].variable.text, instances[3].value.text)
func instance(filepath):
	var temp = filepath.instance()
	add_child(temp)
	return temp

func edit_add_variable(variable, value):
	variables[str(variable)] = value
	
func identify_instance():
	var type
	type = instances.size() + 1
	return type
		
