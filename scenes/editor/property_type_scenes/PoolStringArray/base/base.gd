extends Control

export var line_edit : NodePath

var pressed = false
var last_hovered = false

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
onready var text = $LineEdit

var dialogue: PoolStringArray = ["Text"]

func _ready():
	text.connect("button_down", self, "pressed")
	
func _process(_delta):
	if text.is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = text.is_hovered()

func pressed():
	if pressed == false:
		click_sound.play()
		var window = preload("res://scenes/editor/property_type_scenes/PoolStringArray/base/DialogueInput.tscn")
		var window_child = window.instance()
		Singleton2.disable_hotkeys = true
		get_parent().get_parent().get_parent().get_parent().add_child(window_child)
		window_child.set_as_toplevel(true)
		window_child.get_node("Contents/TextEdit").text = dialogue[0]
		window_child.get_node("Contents/CancelButton").string = self
		window_child.get_node("Contents/SaveButton").string = self
		pressed = true


func set_value(value: PoolStringArray):
	dialogue = value

func get_value() -> PoolStringArray:
	return dialogue

func update_value():
	pressed = false
	get_node("../").update_value(get_value())
