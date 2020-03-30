extends Control

export var button : NodePath

onready var button_node : Button = get_node(button)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var value = true
var last_hovered = false

func _ready():
	button_node.connect("pressed", self, "pressed")
	
func pressed():
	click_sound.play()
	set_value(!value)
	update_value()

func set_value(value: bool):
	self.value = value
	button_node.text = "True" if value else "False"

func get_value() -> bool:
	return value

func update_value():
	get_node("../").update_value(get_value())

func _process(delta):
	if button_node.is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = button_node.is_hovered()
