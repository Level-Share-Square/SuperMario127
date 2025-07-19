class_name SelectionBox
extends NinePatchRect
## Object selector for the level designer.

onready var editor = get_owner().get_owner()
onready var ui = get_parent().get_node("%UI")
onready var selection_area = $SelectionArea
onready var selection_shape = $SelectionArea/SelectionShape
onready var white_highlight = $WhiteHighlight
onready var selection_tools = $SelectionTools
onready var edit_selection = $"%EditSelection"
onready var pivot = get_parent().get_node("Pivot")
onready var pivot_toggle = $EditSelection/ButtonContainer/PivotToggleButton

onready var sel_border = preload("res://scenes/editor/tools/selection_box/selection_border.png")
## Delay between animation steps in frames.
export var animation_delay: float = 6
export var frame_count: int = 5

var timer: float = 0

var start_pos: Vector2
var selected_dict = {}

var pivot_position = Vector2(0, 0)
var expand: bool = false
var erase: bool = true


func _ready():
	hide()
	pivot.hide()
	selection_shape.disabled = true
	selection_area.monitorable = false
	timer = animation_delay
	selection_area.connect("area_entered", self, "_on_object_entered")
	pivot_toggle.connect("button_down", pivot, "on_toggle")


func hide_selection_box():
	hide()
	if pivot_toggle.pressed:
		pivot.visible = false
	self_modulate.a = 0
	rect_size = Vector2.ZERO
	rect_scale = Vector2.ONE
	expand = false
	selection_area.monitorable = false
	selection_shape.disabled = true
	snap_to_selected_size()

func show_selection_box():
	show()
	if pivot_toggle.pressed:
		pivot.visible = true
	self_modulate.a = 1
	rect_scale = Vector2.ONE
	white_highlight.hide()
	erase = false
	expand = false
	selection_area.monitorable = false
	selection_shape.disabled = true
	snap_to_selected_size()


func _unhandled_input(event):
	if selection_tools.active_tool == null:
		if event.is_action_pressed("middle") and editor.hovered_objects.empty():
			pivot_toggle.pressed = false
			pivot.hide()
			pivot_position = Vector2.ZERO
			if not editor.selected_objects.empty():
				var action := SelectObjectsAction.new()
				action.editor = editor
				action.selection_box = self
				action.selected_objects = {}
				editor.action_manager.commit_action(action)
			else:
				hide_selection_box()
			
			edit_selection.hide()
			rect_size = Vector2(0, 0)
			start_pos = get_global_mouse_position()
			rect_position = start_pos
			
			white_highlight.visible = true
			erase = true
			expand = true
			selection_shape.disabled = false
			selection_area.monitorable = true
		
		elif event.is_action_released("middle"):
			if start_pos != null:
				white_highlight.visible = false
				expand = false
				if not (editor.selected_objects.empty() and selected_dict.empty()):
					var action := SelectObjectsAction.new()
					action.editor = editor
					action.selection_box = self
					action.selected_objects = selected_dict
					editor.action_manager.commit_action(action)
				else:
					hide_selection_box()


func _process(delta):
	white_highlight.rect_size = rect_size
	if not visible: return
		
	timer = max(timer - 1, 0)

	if timer <= 0:
		region_rect.position.x = wrapi(
			region_rect.position.x + region_rect.size.x,
			0,
			frame_count * region_rect.size.x
		)
		timer = animation_delay
		
	if selection_tools.active_tool == null:
		if expand == true:
			box_expansion()

func _on_object_entered(area, object):
	if expand == true:
		selected_dict.get_or_add(object, object.name)
		object.modulate = Color(0.7, 0.7, 1.2, object.modulate.a)


func _on_object_exited(area, object):
	if erase == true:
		selected_dict.erase(object)
		object.modulate = Color(1, 1, 1, object.modulate.a)


func box_expansion():
	rect_size.x = abs(start_pos.x - get_global_mouse_position().x)
	rect_size.y = abs(start_pos.y - get_global_mouse_position().y)
	
	selection_shape.position = Vector2(rect_size.x/2, rect_size.y/2)
	selection_shape.shape.extents = Vector2(rect_size.x/2, rect_size.y/2)
	
	if start_pos.x - get_global_mouse_position().x > 0:
		rect_rotation = 180
		rect_scale.y = -1
		rect_scale.x = 1
	else:
		rect_rotation = 0
		rect_scale.y = 1
		rect_scale.x = 1
		
	if start_pos.y - get_global_mouse_position().y > 0:
		rect_rotation = 180 if start_pos.x - get_global_mouse_position().x < 0 else 0
		rect_scale.x = -1
	else:
		rect_rotation = 0 if start_pos.x - get_global_mouse_position().x < 0 else 180
		rect_scale.x = 1


func snap_to_selected_size():
	var far_left = 999999999
	var far_right = -999999999
	var far_up = 999999999
	var far_down = -999999999
	for object in editor.selected_objects:
		if object.global_position.x > far_right:
			far_right = object.global_position.x
		if object.global_position.x < far_left:
			far_left = object.global_position.x
		if object.global_position.y < far_up: 
			far_up = object.global_position.y
		if object.global_position.y > far_down:
			far_down = object.global_position.y
		
	rect_position = Vector2(far_left, far_up)
	rect_size = Vector2(abs(far_left - far_right), far_down - far_up)
	if selection_tools.active_tool == null:
		match rect_scale:
			Vector2(-1, 1):
				rect_scale = Vector2(-1, -1)
			Vector2(-1, -1):
				rect_scale = Vector2(1, 1)
			Vector2(1, -1):
				rect_scale = Vector2(-1, -1)
			Vector2(1, 1):
				rect_scale = Vector2(-1, -1)
				
		edit_selection.show()
		rect_rotation = 180


func toggle_ui(is_visible: bool):
	ui.visible = is_visible
	visible = is_visible
	if pivot_toggle.pressed:
		pivot.visible = is_visible
	
