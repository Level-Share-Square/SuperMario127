extends Selector

onready var selection_area: Area2D = get_node("%SelectionArea")
onready var selection_shape: CollisionShape2D = get_node("%SelectionShape")

func _ready():
	._ready()
	
	selection_area.connect("area_entered", self, "_on_object_entered")
	selection_area.connect("area_exited", self, "_on_object_exited")

func get_adjusted_mouse_position():
	return get_global_mouse_position()
	
	
func reset_bounds():
	.reset_bounds()
	
	editor.selected_objects = {}

func box_expansion():
	.box_expansion()
	selection_shape.shape.extents = fill_rect.size/2
	selection_shape.global_position = fill_rect.position + selection_shape.shape.extents

func _on_object_entered(area):
	if !area.owner is GameObject:
		return
	var object = area.owner as GameObject
	print(shared.get_layer_index(object.level_layer_ref.get_ref()), editor.layer)
	if editor.layer == shared.get_layer_index(object.level_layer_ref.get_ref()):
		editor.selected_objects.get_or_add(object)
		object.selected = true
	pass

func _on_object_exited(area):
	if !area.owner is GameObject:
		return
	var object = area.owner as GameObject
	if editor.layer == shared.get_layer_index(object.level_layer_ref.get_ref()):
		editor.selected_objects.erase(object)
		object.selected = false
	pass

func on_mouse_released():
	if editor.selected_objects.empty():
		reset_bounds()
		return
		
	fit_to_bounding_rectangle()
	set_highlight_mode(false)
	
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
		
	var rect := Rect2(editor.selected_objects.keys()[0].position, Vector2(0, 0))
	
	for object in editor.selected_objects:
		rect = rect.expand(object.position)
		
	return rect
