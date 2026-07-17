extends NinePatchRect

class_name OldEditorWindow

signal window_opened

onready var close_button = $CloseButton
onready var hover_sound = $CloseButton/HoverSound
onready var click_sound = $CloseButton/ClickSound

##Scripting add new variable
#onready var save_button = $Contents/SaveButton
#onready var cancel_button = $Contents/CancelButton
#onready var variable_name = $Contents/TextEdit
#
##Scripting add new operation
#onready var newvar = $VBoxContainer/NewVar
#onready var position_edit = $VBoxContainer/Position
#onready var if_edit = $VBoxContainer/If
#onready var while_edit = $VBoxContainer/While
#onready var collision_edit = $VBoxContainer/Collision
#onready var scale_edit = $VBoxContainer/Scale
#onready var visibility_edit = $VBoxContainer/Visibility

onready var tween = $Tween
var drag_position = null
var hovered: bool = false

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_global_mouse_position() - rect_global_position
			raise()
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position

func reopen()-> void:
	
	emit_signal("window_opened")
	if !visible:
		visible = true
		tween.interpolate_property(self, "rect_scale",
			Vector2(0, 0), Vector2(0.4, 0.4), 0.15,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
		EditorState.disable_hotkeys = true
	
	var back_button = get_parent().get_node_or_null("BackButton")
	
	if (!is_instance_valid(back_button)): # For text input windows
		back_button = get_parent().get_parent().get_parent().get_node("BackButton")
		
	if (!back_button.is_connected("open_quit_wo_saving_popup",self,"temporary_close")):
		back_button.connect("open_quit_wo_saving_popup",self,"temporary_close")
	
	if (!is_connected("mouse_entered",self,"on_mouse_entered")):
	
		connect("mouse_entered",self,"on_mouse_entered")
		connect("mouse_exited",self,"on_mouse_exited")
	
	var current_parents = [self]
	var current_children: Array
	var max_iterations = 10
	var current_iteration = 1
	
	while (array_has_children(current_parents) and current_iteration < max_iterations):
		
		current_children = get_array_children(current_parents)
		
		for child in current_children:
			if (child.has_signal("mouse_entered") and !(
				child.is_connected("mouse_entered",self,"on_mouse_entered"))):
			
				child.connect("mouse_entered",self,"on_mouse_entered")
				child.connect("mouse_exited",self,"on_mouse_exited")
		
		current_parents = Array(current_children)
		current_iteration += 1

func add_window(window)-> void:
	
	var quit_wo_saving_window = get_parent().get_node("BackButton").get_node("QuitWOSavingWindow")
	quit_wo_saving_window.add_window(window)

func open():
	
	reopen()
	add_window(self)

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

func temporary_close()-> void:
	if visible:
		rect_scale = Vector2(0.4, 0.4)
		tween.interpolate_property(self, "rect_scale",
			Vector2(0.4, 0.4), Vector2(0, 0), 0.15,
			Tween.TRANS_CIRC, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		visible = false
		EditorState.disable_hotkeys = false

func close():
	
	var quit_wo_saving_window
	if (get_parent().name == "UI"):
		quit_wo_saving_window = get_parent().get_node("BackButton").get_node("QuitWOSavingWindow")
	else:
		quit_wo_saving_window = get_parent().get_parent().get_parent().get_node("BackButton").get_node("QuitWOSavingWindow")
	quit_wo_saving_window.remove_window(self)
	
	temporary_close()

func _ready():
	close_button.texture_normal = load(close_button.texture_normal.load_path)
	close_button.texture_hover = load(close_button.texture_hover.load_path)
	close_button.texture_pressed = load(close_button.texture_pressed.load_path)
	var _connect = close_button.connect("mouse_entered", self, "hover")
	var _connect2 = close_button.connect("pressed", self, "pressed")

func hover():
	hover_sound.play()

func pressed():
	close()
	click_sound.play()
	
func is_open() -> bool:
	return visible

func on_mouse_entered()-> void:
	hovered = true

func on_mouse_exited()-> void:
	hovered = false
