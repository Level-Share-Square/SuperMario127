extends NinePatchRect

class_name EditorWindow

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

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_global_mouse_position() - rect_global_position
			raise()
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position

func open():
	emit_signal("window_opened")
	if !visible:
		visible = true
		tween.interpolate_property(self, "rect_scale",
			Vector2(0, 0), Vector2(0.4, 0.4), 0.15,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
		Singleton2.disable_hotkeys = true
	
func close():
	if visible:
		rect_scale = Vector2(0.4, 0.4)
		tween.interpolate_property(self, "rect_scale",
			Vector2(0.4, 0.4), Vector2(0, 0), 0.15,
			Tween.TRANS_CIRC, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		visible = false
		Singleton2.disable_hotkeys = false

func _ready():
	close_button.texture_normal = load(close_button.texture_normal.load_path)
	close_button.texture_hover = load(close_button.texture_hover.load_path)
	close_button.texture_pressed = load(close_button.texture_pressed.load_path)
	var _connect = close_button.connect("mouse_entered", self, "hovered")
	var _connect2 = close_button.connect("pressed", self, "pressed")

func hovered():
	hover_sound.play()

func pressed():
	close()
	click_sound.play()
	
func is_open() -> bool:
	return visible
