class_name SelectionBox
extends EditorTool
## Object selector for the level designer.

onready var selection_box = $"%SelectionBox"
onready var ui = get_node("%UI")
onready var selection_area = $"%SelectionArea"
onready var selection_shape = $"%SelectionShape"
onready var white_highlight = $"%WhiteHighlight"
onready var selection_tools = $"%SelectionTools"
onready var edit_selection = $"%EditSelection"
onready var pivot = get_node("Pivot")
onready var pivot_toggle = $"%PivotToggleButton"
onready var vseparator3 = $"%VSeparator3"
onready var item_actions = $"%ItemActions"
onready var object_settings_window = $"%ObjectSettingsWindow"

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


func hide_selection_box():
	hide()
	pivot.visible = false
	selection_box.self_modulate.a = 0
	selection_box.rect_size = Vector2.ZERO
	selection_box.rect_scale = Vector2.ONE
	edit_selection.hide()
	expand = false
	selection_area.monitorable = false
	selection_shape.disabled = true

func show_selection_box():
	show()
	if pivot_toggle.pressed:
		pivot.visible = true
	selection_box.self_modulate.a = 1
	selection_box.rect_scale = Vector2.ONE
	white_highlight.hide()
	erase = false
	expand = false
	selection_area.monitorable = false
	selection_shape.disabled = true
	edit_selection.show()
	item_actions.show_selection_actions()
	pivot_toggle.show()
	vseparator3.show()
	snap_to_selected_size()

func _unhandled_input(event):
	if editor.tool_manager.current_tool == self:
		if selection_tools.active_tool == null:
			if event.is_action_pressed("LMB") and editor.hovered_objects.empty():
				pivot_toggle.pressed = false
				pivot.hide()
				pivot_position = Vector2.ZERO
				if not editor.selected_objects.empty():
					var action := SelectObjectsAction.new()
					action.editor = editor
					action.selection_box = selection_box
					action.selected_objects = {}
					editor.action_manager.commit_action(action)
				else:
					hide_selection_box()
				
				edit_selection.hide()
				selection_box.rect_size = Vector2(0, 0)
				start_pos = get_global_mouse_position()
				selection_box.rect_position = start_pos
				
				white_highlight.visible = true
				erase = true
				expand = true
				selection_shape.disabled = false
				selection_area.monitorable = true
				print(editor.selected_objects)
			
			elif event.is_action_released("LMB"):
				if start_pos != null:
					white_highlight.visible = false
					expand = false
					pivot.reveal_thyself()
					if not (editor.selected_objects.empty() and selected_dict.empty()):
						item_actions.show_selection_actions()
						var action := SelectObjectsAction.new()
						action.editor = editor
						action.selection_box = selection_box
						action.selected_objects = selected_dict
						editor.action_manager.commit_action(action)
					else:
						hide_selection_box()
						item_actions.hide_selection_actions()


func _process(delta):
	white_highlight.rect_size = selection_box.rect_size
	if not visible: return
		
	timer = max(timer - 1, 0)

	if timer <= 0:
		selection_box.region_rect.position.x = wrapi(
			selection_box.region_rect.position.x + selection_box.region_rect.size.x,
			0,
			frame_count * selection_box.region_rect.size.x
		)
		timer = animation_delay
		
	if selection_tools.active_tool == null:
		if expand == true:
			box_expansion()

func _on_object_entered(area, object):
	if expand == true:
		if editor.show_layers:
			if editor.layer == object.layer:
				selected_dict.get_or_add(object, object.name)
				object.selected = true
			else:
				return
		else:
			selected_dict.get_or_add(object, object.name)
			object.selected = true

func _on_object_exited(area, object):
	if erase == true:
		if editor.show_layers:
			if editor.layer == object.layer:
				selected_dict.erase(object)
				object.selected = false
			else:
				return
		else:
			selected_dict.erase(object)
			object.selected = false


func box_expansion():
	selection_box.rect_size.x = abs(start_pos.x - get_global_mouse_position().x)
	selection_box.rect_size.y = abs(start_pos.y - get_global_mouse_position().y)
	
	selection_shape.position = Vector2(selection_box.rect_size.x/2, selection_box.rect_size.y/2)
	selection_shape.shape.extents = Vector2(selection_box.rect_size.x/2, selection_box.rect_size.y/2)
	
	if start_pos.x - get_global_mouse_position().x > 0:
		selection_box.rect_rotation = 180
		selection_box.rect_scale.y = -1
		selection_box.rect_scale.x = 1
	else:
		selection_box.rect_rotation = 0
		selection_box.rect_scale.y = 1
		selection_box.rect_scale.x = 1
		
	if start_pos.y - get_global_mouse_position().y > 0:
		selection_box.rect_rotation = 180 if start_pos.x - get_global_mouse_position().x < 0 else 0
		selection_box.rect_scale.x = -1
	else:
		selection_box.rect_rotation = 0 if start_pos.x - get_global_mouse_position().x < 0 else 180
		selection_box.rect_scale.x = 1


func snap_to_selected_size():
	if editor.selected_objects.empty():
		hide_selection_box()
		return
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
		
	selection_box.rect_position = Vector2(far_left, far_up)
	selection_box.self_modulate.a = 1 if editor.selected_objects.size() > 1 else 0
	selection_box.rect_size = Vector2(abs(far_left - far_right), far_down - far_up)
	if selection_tools.active_tool == null:
		match selection_box.rect_scale:
			Vector2(-1, 1):
				selection_box.rect_scale = Vector2(-1, -1)
			Vector2(-1, -1):
				selection_box.rect_scale = Vector2(1, 1)
			Vector2(1, -1):
				selection_box.rect_scale = Vector2(-1, -1)
			Vector2(1, 1):
				selection_box.rect_scale = Vector2(-1, -1)
				
		edit_selection.show()
		selection_box.rect_rotation = 180


func toggle_ui(is_visible: bool):
	ui.visible = is_visible
	selection_box.visible = is_visible
	if pivot_toggle.pressed:
		pivot.visible = is_visible
	
	
func on_redo():
	show_selection_box()
	
	
func on_undo():
	show_selection_box()
	
	
func copy():
	if editor.selected_objects != {}:
		var copied_objects: Array
		for i in editor.selected_objects:
			var data: ObjectData = i.level_object.get_ref()
			var properties: Array = []
			for property in data.properties:
				properties.append(value_util.encode_value(property))
			copied_objects.append({"type_id": data.type_id, "palette": data.palette, "properties": properties})
		OS.set_clipboard(JSON.print(copied_objects))
		item_actions.verify_clipboard()

func generate_object_data():
	var data = JSON.parse(OS.get_clipboard())
	var result = data.result
	if result is Array:
		var data_array: Array
		for i in result:
			var object_data = ObjectData.new()
			var properties: Array = []
			for property in i["properties"]:
				properties.append(value_util.decode_value(property))
			object_data.properties = properties
			object_data.palette = i["palette"]
			object_data.type_id = i["type_id"]
			data_array.append(object_data)
		return data_array
	else:
		return []

func paste():
	var object_data = generate_object_data()
	if object_data == []:
		return
	else:
		editor.tool_manager.change_tool(name)
		show_selection_box()
		for object in selected_dict:
			object.selected = false
		selected_dict = {}
		snap_to_selected_size()
		var action = PlaceObjectBulkAction.new()
		action.shared = shared
		action.objects = object_data
		editor.action_manager.commit_action(action)
		while action.new_objects == {}:
			pass
		editor.selected_objects = action.new_objects
		selected_dict = action.new_objects
		show_selection_box()
		item_actions.show_selection_actions()


func _on_Delete_button_down():
	for object in selected_dict:
		object.selected = false
	var action = EraseObjectBulkAction.new()
	action.shared = shared
	action.objects = editor.selected_objects.keys()
	editor.action_manager.commit_action(action)

	editor.selected_objects = {}
	selected_dict = {}
	hide_selection_box()
	item_actions.hide_selection_actions()


func open_properties_window():
	var objects: Dictionary
	for selected_object in editor.selected_objects:
		objects[selected_object] = selected_object.placeable_item
	
	object_settings_window.load_objects(objects)
