extends Control

export var button : NodePath

onready var button_node : Button = get_node(button)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound


#Parameter one is amount of options, parameter two is the lowest value, parameter three is the list of values to display, set to null for the default
var parameters : Array = [["null"], 0, null]

var value_index : int = 0
var actual_value := ""
var last_hovered = false

func _ready():
	var _connect = button_node.connect("pressed", self, "pressed")
	yield(get_tree(), "idle_frame")
	if parameters[2] != null:
		button_node.text = parameters[2][value_index]
	else:
		var text: String = parameters[0][value_index]
		if typeof(text) == TYPE_STRING:
			text = text.capitalize()
		

func pressed():
	click_sound.play()
	set_value(value_index+1)
	update_value()

func set_value(_value):
	if typeof(_value) == TYPE_INT:
		value_index = _value
		value_index = wrapi(value_index, 0, parameters[0].size())
		actual_value = parameters[0][value_index]
		# Does object have an alias for the string value?
		if parameters[2] != null:
			var text: String = parameters[0][value_index]
			if typeof(text) == TYPE_STRING:
				text = text.capitalize()
			button_node.text = parameters[2][value_index]
		else:
			# Default to the string value otherwise
			button_node.text = actual_value
		
	elif typeof(_value) == TYPE_STRING:
		actual_value = _value
		
		if actual_value in parameters[0]:
			value_index = parameters[0].find(actual_value)
		else:
			value_index = 0
	

func get_value() -> String:
	return parameters[0][value_index]

func update_value():
	get_parent().update_value(get_value())

func _process(_delta):
	if button_node.is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = button_node.is_hovered()
