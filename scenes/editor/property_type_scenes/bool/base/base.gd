extends Control

export var button : NodePath

onready var button_node : Button = get_node(button)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var value = true
var last_hovered = false

func _ready():
	var _connect = button_node.connect("pressed", self, "pressed")

func pressed():
	click_sound.play()
	set_value(!value)
	update_value()

func set_value(_value: bool):
	value = _value
	
	# Does object have a name for the value?
	var p := get_parent()
	if p.object.property_value_to_name.has(p.key) && p.object.property_value_to_name[p.key].has(value):
		button_node.text = p.object.property_value_to_name[p.key][value]
	else:
		# Default to true/false otherwise
		button_node.text = "True" if value else "False"

func get_value() -> bool:
	return value

func update_value():
	get_parent().update_value(get_value())

func _process(_delta):
	if button_node.is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = button_node.is_hovered()
