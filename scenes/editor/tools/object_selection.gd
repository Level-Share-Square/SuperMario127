extends Selector
class_name ObjectSelector

onready var pivot = $"%Pivot"

func _ready():
	._ready()
	
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "fit_to_bounding_rectangle")
	editor.action_manager.connect("redo", self, "fit_to_bounding_rectangle")
	editor.action_manager.connect("action", self, "fit_to_bounding_rectangle")
	tool_manager.get_node("ObjectPaint").connect("objects_selected", self, "external_objects_selected")

func get_adjusted_mouse_position():
	return get_global_mouse_position()
	
func toggle_ui(value: bool):
	editor.ui.visible = value
	
func reset_bounds():
	.reset_bounds()
	
	editor.selected_objects = []
	pivot.visible = false

func on_mouse_released():
	select_objects(shared.get_layer_at(editor.layer).find_objects_in_rect(fill_rect))
	if editor.selected_objects.empty():
		reset_bounds()
		return
		
	run_selection_behavior()
	
func external_objects_selected(objects: Array):
	select_objects(objects)
	if editor.selected_objects.empty():
		reset_bounds()
		return
	run_selection_behavior()
	
func run_selection_behavior():
	fit_to_bounding_rectangle()
	set_highlight_mode(false)
	pivot.visible = pivot.pivot_toggle.pressed
	pivot.rect_global_position = pivot.get_position_centered()
	editor.item_actions.show_selection_actions()
	action()
	
func action():
	var action := SelectObjectsAction.new()
	action.editor = editor
	action.selected_objects = editor.selected_objects
	editor.action_manager.commit_action(action)
	
func fit_to_bounding_rectangle():
	fill_rect = get_bounding_rectangle()
	if !fill_rect:
		reset_bounds()
		return
	
	var layer = shared.get_layer_at(editor.layer)
	
	var drag_rect = fill_rect
	
	if layer is LevelParallaxLayer:
		drag_rect = layer.parallax_scroll.get_global_transform().xform(drag_rect)
		
	highlight.rect_global_position = drag_rect.position
	highlight.rect_size = drag_rect.size
	
	selection_box.rect_global_position = drag_rect.position
	selection_box.rect_size = drag_rect.size
	

func get_bounding_rectangle():
	for object in editor.selected_objects.duplicate():
		if !object.is_inside_tree():
			editor.selected_objects.erase(object)
			
	if editor.selected_objects.empty():
		return Rect2()
		
	var rect := Rect2(editor.selected_objects[0].position, Vector2(0, 0))
	
	for object in editor.selected_objects:
		rect = rect.merge(object.get_global_editor_rect())
		
	return rect
	
func _click_left(event, mouse_position):
	select_objects([])
	if fill_rect.has_point(get_adjusted_mouse_position()):
		fill_rect = Rect2()
	._click_left(event, mouse_position)


func on_copy():
	if editor.tool_manager.current_tool == self:
		if editor.selected_objects.empty(): return
		
		var objects: Array = []
		for object in editor.selected_objects:
			objects.append(object.object_data)
		
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
	if !editor.selected_objects.empty():
		var action := EraseObjectBulkAction.new()
		action.shared = shared
		action.layer = editor.layer
		action.objects = editor.selected_objects
		editor.selected_objects = []
		editor.action_manager.commit_action(action)
		action.connect("delete_undo", self, "on_undid_delete")
		
func on_undid_delete(objects):
	editor.selected_objects = objects

func select_objects(objects):
	for object in editor.selected_objects:
		object.selected = false
	editor.selected_objects = objects
	for object in objects:
		object.selected = true
