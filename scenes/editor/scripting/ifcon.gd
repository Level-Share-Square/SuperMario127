extends WindowDialog

onready var value = $Value
onready var variables = $Var
onready var condition_picker = $Selector
onready var camera = $"../PanningCamera2D"
onready var scripting = get_parent()
var appended_variables = []
var can_drag = false

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
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


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
	
	
	
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	value.connect("text_changed", self, "_on_Value_text_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.





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

