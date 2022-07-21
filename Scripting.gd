extends Control

var use_n_o = false
var variable_num = -1
onready var camera = get_node("PanningCamera2D")
onready var window_node = $AddBlockWindow
onready var camera_pos = $CanvasLayer/Label2
const var_name_popup = preload("res://scenes/editor/window/VarNameWindow.tscn")
const new_var = preload("res://scenes/editor/scripting/newvar.tscn")
const if_con = preload("res://scenes/editor/scripting/ifcon.tscn")
const line = preload("res://scenes/editor/scripting/Line2D.tscn")
var instances = []
var variables : Dictionary = {}
var variable_list #Gets a list of all the keys in the variables dictionary in an array to display in the variable window
var can_create_line = false
var line_created = false
var can_connect = false

func _process(_delta):
	print(variables)
	camera_pos.text = "(" + str(round(camera.position.x)) + "," + str(round(camera.position.y)) + ")"
	if Input.is_action_just_pressed("RMB"):
		if window_node.visible:
			window_node.close()
			window_node.rect_position = get_global_mouse_position()
		else:
			window_node.rect_position = get_global_mouse_position()
			window_node.open()


	#Variables
	if window_node.newvar.pressed == true && use_n_o == false: #If the New Variable button is spressed
		instances.append(instance(var_name_popup)) #Creates the naming pop-up and appends it to an instances array
		instances[instances.size() - 1].open() #Runs open() in the naming pop-up
		use_n_o = true #Sets this variable to true that makes this magically work somehow idk
	if use_n_o == true:
		if "VarNameWindow" in str(instances[instances.size() - 1]):
			if instances[instances.size() - 1].cancel_button.pressed == true:
				#instances.size() returns an int value that doesnt start from 0 so I have to subtract 1
				#to make it check the latest instance.
				use_n_o = false
			if instances[instances.size() - 1].close_button.pressed == true:
				use_n_o = false
			if instances[instances.size() - 1].save_button.pressed == true:
				add_var()


	#If Conditions
	if window_node.if_edit.pressed == true && use_n_o == false: #If the If Condition button is pressed
		instances.append(instance(if_con)) #Creates the if condition and adds it to the instances array
		use_n_o = true #Sets this variable to true that makes this magically work somehow idk
		yield(get_tree().create_timer(1), "timeout")
		use_n_o = false

func instance(filepath):
	var temp = filepath.instance()
	add_child(temp)
	return temp

func edit_add_variable(variable, value):
	variables[str(variable)] = value

func add_var():
	variable_num += 1 #Adds 1 to variable_num (initially 0)
	edit_add_variable(instances[instances.size() - 1].variable_name.text, null) #Adds a new faux-variable to the dictionary that has the name of the LineEdit for the key and null for the value
	instances[instances.size() - 1].close() 
	instances.append(instance(new_var)) #Creates the variable window and appends it to the instances array
	use_n_o = false #Turns this to false which, again, I have no idea why this makes it work
	variable_list = variables.keys()
	instances[instances.size() - 1].variable.text = variable_list[variable_num] #Changes the text of the "Var" part of the variable window to the latest entry in the variable_list array (which is found by using the variable_num variable)
		
