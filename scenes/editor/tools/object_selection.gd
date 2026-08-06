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

func _draw():
	draw_rect(fill_rect, Color.webmaroon)

func _process(_delta):
	update()

func get_adjusted_mouse_position():
	return get_mouse_pos()
	
func toggle_ui(value: bool):
	editor.ui.visible = value
	
func reset_bounds():
	.reset_bounds()
	editor.item_actions.handle_selection()
	editor.selected_objects = []
	pivot.visible = false

func on_mouse_released():
	select_objects(shared.get_layer(editor.layer).find_objects_in_rect(
		parallax_scroll.get_global_transform().xform(fill_rect)))
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
	editor.item_actions.handle_selection()
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
		editor.item_actions.handle_selection()
		return
	
	var drag_rect = fill_rect
	var layer = shared.get_layer(editor.layer)
	if layer is LevelParallaxLayer:
		drag_rect = parallax_scroll.get_global_transform().xform(drag_rect)
		drag_rect.size /= parallax_scroll.scale
		
	highlight.rect_global_position = drag_rect.position
	highlight.rect_size = drag_rect.size
	
	selection_box.rect_global_position = drag_rect.position
	selection_box.rect_size = drag_rect.size
	
func get_bounding_rectangle() -> Rect2:
	for object in editor.selected_objects.duplicate():
		if !object.is_inside_tree():
			editor.selected_objects.erase(object)
	
	if editor.selected_objects.empty():
		return Rect2()
	
	var rect := Rect2()
	var first_selected: bool = true
	
	for object in editor.selected_objects:
		var new_rect: Rect2 = object.get_global_editor_rect()
		new_rect = to_local(new_rect)

		if first_selected:
			rect = new_rect
			first_selected = false
		else:
			rect = rect.merge(new_rect)

	return rect

func to_local(global_rect: Rect2) -> Rect2:
	var inv: Transform2D = parallax_scroll.get_global_transform().affine_inverse()
	
	var p1: Vector2 = inv.xform(global_rect.position)
	var p2: Vector2 = inv.xform(global_rect.position + Vector2(global_rect.size.x, 0))
	var p3: Vector2 = inv.xform(global_rect.position + Vector2(0, global_rect.size.y))
	var p4: Vector2 = inv.xform(global_rect.position + global_rect.size)
	
	var min_pos := Vector2(
		min(p1.x, min(p2.x, min(p3.x, p4.x))),
		min(p1.y, min(p2.y, min(p3.y, p4.y)))
	)
	var max_pos := Vector2(
		max(p1.x, max(p2.x, max(p3.x, p4.x))),
		max(p1.y, max(p2.y, max(p3.y, p4.y)))
	)
	
	return Rect2(min_pos, max_pos - min_pos)

func _click_left(event, mouse_position):
	select_objects([])
	if fill_rect.has_point(get_adjusted_mouse_position()):
		fill_rect = Rect2()
	._click_left(event, mouse_position)
		
func on_undid_delete(objects):
	editor.selected_objects = objects

func select_objects(objects):
	for object in editor.selected_objects:
		object.selected = false
	editor.selected_objects = objects
	for object in objects:
		object.selected = true
