extends WindowDialog

onready var value = $Value
onready var variables = $Var
onready var condition_picker = $Selector
onready var scripting = get_parent()
var appended_variables = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_close_button().visible = false
	visible = true
	condition_picker.add_item("=")
	condition_picker.add_item(">=")
	condition_picker.add_item("<=")
	condition_picker.add_item("!=")
	condition_picker.add_item("+")
	condition_picker.add_item("-")



func _process(delta):
	if scripting.instances.size() > 0:
		if "NewVar" in str(scripting.instances[scripting.instances.size() - 1]): #Checks if the newest added instance has the words "NewVar"
			if !appended_variables.has(get_newest_var()): #Checks if the newest variable is already added to the list
				variables.add_item(get_newest_var()) #Adds the newest variable to the list (the name comes from the list of keys in the variables dictionary)
				appended_variables.append(get_newest_var()) #Appends the newest variable to the appended_variables array so that the game can check if it's already there or not
			
func get_newest_var() -> String:
	var variable
	variable = scripting.variable_list[scripting.variable_num] #Gets the name of the variable from the variable_list array (holds all the keys in the variables dictionary)
	return variable #Returns the value of variable to be used in the code in _process()
