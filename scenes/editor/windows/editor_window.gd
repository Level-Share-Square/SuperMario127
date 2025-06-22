class_name EditorWindow
extends Popup


export(NodePath) var window_panel_path
export(NodePath) var drag_control_path
export(NodePath) var close_button_path

export var title: String
export var icon: Texture
export var icon_tooltip: String
export var window_size: Vector2

var drag_position: Vector2

onready var title_node: RichTextLabel = $WindowBack/WindowMat/HeaderContentDivider/HeaderMat/HeaderBox/Title
onready var icon_node: TextureRect = $WindowBack/WindowMat/HeaderContentDivider/HeaderMat/HeaderBox/Icon


func set_title(val: String):
	title_node.bbcode_text = val
	title_node.bbcode_enabled = true


func set_icon(val):
	icon_node.texture = val


func set_tooltip(val):
	icon_node.hint_tooltip = val


func _ready() -> void:
	var window_panel: PanelContainer = get_node(window_panel_path)
	
	var drag_control: Control = get_node(drag_control_path)
	drag_control.connect("gui_input", self, "drag_window")
	
	var close_button: BaseButton = get_node(close_button_path)
	close_button.connect("pressed", self, "close")
	
	# I don't know why, but if you don't pop the window up first the 
	# minimum size is never calculated
	popup_centered(Vector2(0, 0))
	
	rect_min_size = window_panel.get_combined_minimum_size()
	
	rect_min_size.x = max(rect_min_size.x, window_size.x)
	rect_min_size.y = max(rect_min_size.y, window_size.y)
	
	rect_size = rect_min_size
	
	if not self == get_tree().current_scene:
		hide()
	
	set_title(title)
	
	set_icon(icon)
	set_tooltip(icon_tooltip)


func close():
	var focus: Control = get_focus_owner()
	focus.grab_focus()
	hide()


func drag_window(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_local_mouse_position()
			raise()
	if (event is InputEventMouseMotion) and (event.button_mask == BUTTON_LEFT):
		rect_global_position = event.global_position - drag_position


func _on_Settings_pressed():
	pass # Replace with function body.
