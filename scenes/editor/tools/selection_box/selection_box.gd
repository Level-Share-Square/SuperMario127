class_name SelectionBox
extends NinePatchRect
## Object selector for the level designer.

onready var editor = get_owner()
onready var ui = $"%UI"
onready var selection_area = $SelectionArea
onready var selection_shape = $SelectionArea/SelectionShape
onready var white_highlight = $WhiteHighlight
onready var selection_tools = $SelectionTools
onready var edit_selection = $"%EditSelection"

onready var sel_border = preload("res://scenes/editor/tools/selection_box/selection_border.png")
## Delay between animation steps in frames.
export var animation_delay: float = 6
export var frame_count: int = 5

var timer: float = 0

var pos1

var selected_dict = {}

var expand: bool = false
var erase: bool = true


func _ready():
	hide()
	selection_shape.disabled = true
	selection_area.monitorable = false
	timer = animation_delay
	selection_area.connect("area_entered", self, "_on_object_entered")


func _unhandled_input(event):
	if selection_tools.active_tool == null:
		if event.is_action_pressed("middle"):
			edit_selection.hide()
			rect_size = Vector2(0, 0)
			pos1 = get_global_mouse_position()
			rect_position = pos1
			if editor.hovered_objects.empty():
				for object in editor.selected_objects:
					object.modulate = Color(1, 1, 1, object.modulate.a)
				editor.selected_objects = {}
				selected_dict = {}
				texture = Texture.new()
				yield(get_tree().create_timer(0.1), "timeout")
				white_highlight.visible = true
				erase = true
				expand = true
				selection_shape.disabled = false
				selection_area.monitorable = true
			
		elif event.is_action_released("middle"):
			if pos1 != null:
				white_highlight.visible = false
				texture = AtlasTexture.new()
				texture.atlas = sel_border
				texture.region = Rect2(0, 0, 28, 28)
				if abs(pos1.length() - get_global_mouse_position().length()) < 10:
					hide()
					rect_size = Vector2(0, 0)
					expand = false
					for object in editor.selected_objects:
						object.modulate = Color(1, 1, 1, object.modulate.a)
					editor.selected_objects = {}
					selection_area.monitorable = false
					selection_shape.disabled = true
				else:
					for object in selected_dict:
						editor.selected_objects[object] = selected_dict[object]
						object.modulate = Color(0.8, 0.8, 1.2, object.modulate.a)
					erase = false
					expand = false
					selection_area.monitorable = false
					selection_shape.disabled = true
					snap_to_selected_size()

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
		editor.selected_objects.get_or_add(object, object.name)
		selected_dict.get_or_add(object, object.name)
		object.modulate = Color(0.7, 0.7, 1.2, object.modulate.a)


func _on_object_exited(area, object):
	if erase == true:
		editor.selected_objects.erase(object)
		selected_dict.erase(object)
		object.modulate = Color(1, 1, 1, object.modulate.a)


func box_expansion():
	rect_size.x = abs(pos1.x - get_global_mouse_position().x)
	rect_size.y = abs(pos1.y - get_global_mouse_position().y)
	
	selection_shape.position = Vector2(rect_size.x/2, rect_size.y/2)
	selection_shape.shape.extents = Vector2(rect_size.x/2, rect_size.y/2)
	
	if pos1.x - get_global_mouse_position().x > 0:
		rect_rotation = 180
		rect_scale.y = -1
		rect_scale.x = 1
	else:
		rect_rotation = 0
		rect_scale.y = 1
		rect_scale.x = 1
		
	if pos1.y - get_global_mouse_position().y > 0:
		rect_rotation = 180 if pos1.x - get_global_mouse_position().x < 0 else 0
		rect_scale.x = -1
	else:
		rect_rotation = 0 if pos1.x - get_global_mouse_position().x < 0 else 180
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
	if selection_tools.active_tool == null or selection_tools.active_tool.name != "Move":
		match rect_scale:
			Vector2(-1, 1):
				rect_scale = Vector2(-1, -1)
			Vector2(-1, -1):
				rect_scale = Vector2(1, 1)
			Vector2(1, -1):
				rect_scale = Vector2(-1, -1)
				
		edit_selection.show()


func toggle_ui(is_visible: bool):
	ui.visible = is_visible
