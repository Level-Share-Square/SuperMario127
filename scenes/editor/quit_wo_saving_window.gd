extends Popup

onready var ok_button = $HBoxContainer/OkButton
onready var cancel_button = $HBoxContainer/CancelButton

var open_window: EditorWindow setget set_open_window
var hovered: bool = false

signal confirmed

func set_open_window(window: EditorWindow)-> void:
	
	open_window = window

func _ready():
	var _connect
	ok_button.connect("pressed", self, "on_ok_pressed")
	cancel_button.connect("pressed", self, "on_cancel_pressed")
	
	connect("mouse_entered",self,"on_mouse_entered")
	connect("mouse_exited",self,"on_mouse_exited")
	
	var current_parents = [self]
	var current_children: Array
	
	while (array_has_children(current_parents)):
		
		current_children = get_array_children(current_parents)
		
		for child in current_children:
			
			if (child.has_signal("mouse_entered")):
			
				child.connect("mouse_entered",self,"on_mouse_entered")
				child.connect("mouse_exited",self,"on_mouse_exited")
		
		current_parents = Array(current_children)

func array_has_children(array:Array)-> bool:
	
	for val in array:
		
		if (val.get_child_count() != 0):
			return true
	
	return false

func get_array_children(array:Array)-> Array:
	
	var children: Array = []
	
	for val in array:
		
		if (val.get_child_count() == 0):
			continue
		
		children += val.get_children()
	
	return children

func on_ok_pressed():
	emit_signal("confirmed")

func on_cancel_pressed():
	visible = false
	
	if (open_window != null):
		open_window.open()

func on_mouse_entered()-> void:
	hovered = true

func on_mouse_exited()-> void:
	hovered = false
