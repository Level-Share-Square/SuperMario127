extends Control

export var line_edit : NodePath

var is_pressed = false
var last_hovered = false
var window_child = null

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
		var window = preload("res://scenes/oldeditor/window/TextInput.tscn")
		window_child = window.instance()
		EditorState.disable_hotkeys = true
		get_parent().get_parent().get_parent().get_parent().add_child(window_child)
		window_child.set_as_toplevel(true)
		window_child.get_node("Contents/TextEdit").text = text.text
		window_child.get_node("Contents/CancelButton").string = self
		window_child.get_node("CloseButton").string = self
		window_child.get_node("Contents/SaveButton").string = self
		toggle_pressed()
		
		var UI = get_tree().root.get_node("Editor/UI")
		UI.get_node("ObjectSettingsWindow").add_window(window_child)
		
		var back_button = UI.get_node("BackButton")
		if (!back_button.is_connected("open_quit_wo_saving_popup",self,"temporary_close")):
			back_button.connect("open_quit_wo_saving_popup",self,"temporary_close")


func temporary_close()-> void:
	
	if (window_child.visible):
		
		window_child.visible = false

func set_value(value: String):
	text.text = value

func get_value() -> String:
	return text.text

func update_value():
	toggle_pressed()
	get_node("../").update_value(get_value())

func toggle_pressed() -> void:
	
	is_pressed = !is_pressed
