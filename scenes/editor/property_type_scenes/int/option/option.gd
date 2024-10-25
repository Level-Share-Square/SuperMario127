extends Control

export var button : NodePath

onready var button_node : Button = get_node(button)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound


#Parameter one is amount of options, parameter two is the lowest value, parameter three is the list of values to display, set to null for the default
var parameters : Array = [1, 0, null]

var value = 0
var last_hovered = false

func _ready():
	var _connect = button_node.connect("pressed", self, "pressed")
	if parameters[2] != null:
		var text: String = parameters[2][0]
		if typeof(text) == TYPE_STRING:
			text = text.capitalize()
		button_node.text = text

func pressed():
	click_sound.play()
	set_value(value+1)
	update_value()

func set_value(_value: int):
	value = _value
	value = wrapi(value, parameters[1], parameters[1]+parameters[0])
	# Does object have a name for the value?
	if parameters[2] != null:
		var text: String = parameters[2][value]
		if typeof(text) == TYPE_STRING:
			text = text.capitalize()
		button_node.text = parameters[2][value]
	else:
		# Default to value otherwise
		button_node.text = str(value)

func get_value() -> int:
	return value

func update_value():
	get_parent().update_value(get_value())

func _process(_delta):
	if button_node.is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = button_node.is_hovered()
