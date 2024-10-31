extends Control

export var button : NodePath

onready var button_node : OptionButton = get_node(button)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound


#Parameter one is amount of options, parameter two is the lowest value, parameter three is the list of values to display, set to null for the default
var parameters : Array = [1, 0, null]

var value = 0
var last_hovered = false

func _ready():
	var _connect = button_node.connect("item_selected", self, "pressed")
	yield()
	if parameters[2] != null:
		for i in range(parameters[0]):
			button_node.add_item(parameters[2][i], parameters[1]+i)
	else:
		for i in range(parameters[0]):
			button_node.add_item(str(parameters[1]+i), parameters[1]+i)
	
	button_node.selected = get_value()

func pressed():
	click_sound.play()
	set_value(button_node.get_selected_id())
	update_value()

func set_value(_value: int):
	value = _value

func get_value() -> int:
	return value

func update_value():
	get_parent().update_value(get_value())

func _process(_delta):
	if button_node.is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = button_node.is_hovered()
