extends Control

export var line_edit : NodePath

var is_pressed = false
var last_hovered = false

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
onready var text = $LineEdit

func _ready():
	text.connect("button_down", self, "pressed")
	
func _process(_delta):
	if text.is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = text.is_hovered()

func pressed():
	if is_pressed == false:
		click_sound.play()
		var window = preload("res://scenes/editor/window/TextInput.tscn")
		var window_child = window.instance()
		Singleton2.disable_hotkeys = true
		get_parent().get_parent().get_parent().get_parent().add_child(window_child)
		window_child.set_as_toplevel(true)
		window_child.get_node("Contents/TextEdit").text = text.text
		window_child.get_node("Contents/CancelButton").string = self
		window_child.get_node("CloseButton").string = self
		window_child.get_node("Contents/SaveButton").string = self
		toggle_pressed()


func set_value(value: String):
	text.text = value

func get_value() -> String:
	return text.text

func update_value():
	toggle_pressed()
	get_node("../").update_value(get_value())

func toggle_pressed() -> void:
	
	is_pressed = !is_pressed
