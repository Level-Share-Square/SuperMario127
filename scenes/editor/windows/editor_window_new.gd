class_name EditorWindow
extends PanelContainer


const popup_anim_duration: float = 0.1

export(NodePath) var drag_control_path
export(NodePath) var close_button_path
export(NodePath) var resize_control_path

export var title: String
export var icon: Texture
export var icon_tooltip: String
export var window_size: Vector2

var drag_position: Vector2

onready var title_node: RichTextLabel = $"%WindowTitle"
onready var icon_node: TextureRect = $"%WindowIcon"


func set_title(val: String):
	title_node.bbcode_text = val
	title_node.bbcode_enabled = true


func set_icon(val):
	icon_node.texture = val


func set_tooltip(val):
	icon_node.hint_tooltip = val


func _ready() -> void:
	hide()
	
	var drag_control: Control = get_node(drag_control_path)
	if is_instance_valid(drag_control):
		drag_control.connect("gui_input", self, "drag_window")
	
	var close_button: BaseButton = get_node(close_button_path)
	if is_instance_valid(close_button):
		close_button.connect("pressed", self, "close")
	
	var resize_control: Control = get_node(resize_control_path)
	if is_instance_valid(resize_control):
		resize_control.connect("gui_input", self, "resize_window")
	
	rect_min_size.x = max(rect_min_size.x, window_size.x)
	rect_min_size.y = max(rect_min_size.y, window_size.y)
	
	popup_centered(window_size)
	
	if not self == get_tree().current_scene:
		hide()
	
	while not is_instance_valid(title_node):
		yield(get_tree(), "idle_frame")
	
	title_node.connect("ready", self, "set_title")
	icon_node.connect("ready", self, "set_icon")
	icon_node.connect("ready", self, "set_tooltip")


func popup(rect: Rect2) -> void:
	if visible:
		return
	
	rect_position = rect.position
	rect_size = rect.size
	rect_pivot_offset = rect_size / 2.0
	rect_scale = Vector2.ZERO
	show()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rect_scale", Vector2.ONE, popup_anim_duration)


func popup_centered(size: Vector2) -> void:
	size = Vector2(max(size.x, rect_min_size.x), max(size.y, rect_min_size.y))
	var position: Vector2 = (get_viewport_rect().size / 2.0) - (size / 2.0)
	
	popup(Rect2(position, size))


func close():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rect_scale", Vector2.ZERO, popup_anim_duration)
	
	yield(tween, "finished")
	
	hide()


func toggle_window(size: Vector2) -> void:
	if visible:
		close()
	else:
		popup_centered(size)


func drag_window(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_local_mouse_position()
			raise()
	
	if (event is InputEventMouseMotion) and (event.button_mask == BUTTON_LEFT):
		rect_global_position = event.global_position - drag_position
	
	var window_rect := Rect2(rect_position, rect_size)
	
	if not window_rect.intersects(get_viewport_rect()):
		hide()


func resize_window(event):
	if (event is InputEventMouseMotion) and (event.button_mask == BUTTON_LEFT):
		rect_size = event.global_position - rect_global_position
	
	var window_rect := Rect2(rect_position, rect_size)
	
	if not window_rect.intersects(get_viewport_rect()):
		hide()
