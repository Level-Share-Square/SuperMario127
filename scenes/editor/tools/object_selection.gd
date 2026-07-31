extends Selector
class_name ObjectSelector

onready var pivot = $"%Pivot"

func _ready():
	._ready()
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "fit_to_bounding_rectangle")
	editor.action_manager.connect("action", self, "fit_to_bounding_rectangle")

func get_adjusted_mouse_position():
	return get_global_mouse_position()
	
func toggle_ui(value: bool):
	editor.ui.visible = value
	
func reset_bounds():
	.reset_bounds()
	
	editor.selected_objects = []
	pivot.visible = false

func on_mouse_released():
	editor.selected_objects = shared.get_layer_at(editor.layer).find_objects_in_rect(fill_rect)
	
	if editor.selected_objects.empty():
		reset_bounds()
		return
	
	fit_to_bounding_rectangle()
	set_highlight_mode(false)
	pivot.visible = pivot.pivot_toggle.pressed
	pivot.rect_global_position = pivot.get_position_centered()
	editor.item_actions.show_selection_actions()
	
func fit_to_bounding_rectangle():
	fill_rect = get_bounding_rectangle()
	if !fill_rect:
		return
	highlight.rect_global_position = fill_rect.position
	highlight.rect_size = fill_rect.size
	
	selection_box.rect_global_position = fill_rect.position
	selection_box.rect_size = fill_rect.size
	

func get_bounding_rectangle():
	if editor.selected_objects.empty():
		return Rect2()
		
	var rect := Rect2(editor.selected_objects[0].position, Vector2(0, 0))
	
	for object in editor.selected_objects:
		rect = rect.expand(object.position)
		
	return rect
	
func _click_left(event, mouse_position):
	if fill_rect.has_point(get_adjusted_mouse_position()):
		fill_rect = Rect2()
	._click_left(event, mouse_position)


func on_copy():
	if editor.tool_manager.current_tool == self:
		if editor.selected_objects.empty(): return
		
		var objects: Array = []
		for object in editor.selected_objects:
			objects.append(object.object_data_ref.get_ref())
		
		OS.set_clipboard(JSON.print([LevelCodeSerializer.serialize_objects(objects), [camera.position.x, camera.position.y]]))
		editor.item_actions.show_selection_actions()


func on_paste():
	if editor.tool_manager.current_tool == self:
		var data = JSON.parse(OS.get_clipboard()).result
		editor.selected_objects = []
		var objects: Array = LevelCodeDeserializer.deserialize_objects_code(data[0])

		for object in objects:
			object = object as ObjectData
			object.metadata.position += camera.position - Vector2(data[1][0], data[1][1])
			
			editor.selected_objects.append(shared.create_object(object, editor.layer, true))
		
		fit_to_bounding_rectangle()


func on_delete():
	if editor.tool_manager.current_tool == self:
		var action := EraseObjectBulkAction.new()
		action.shared = shared
		action.layer = editor.layer
		action.objects = editor.selected_objects
		editor.action_manager.commit_action(action)
		editor.selected_objects = []
		action.connect("delete_undo", self, "on_undid_delete")
		
func on_undid_delete(objects):
	editor.selected_objects = objects
