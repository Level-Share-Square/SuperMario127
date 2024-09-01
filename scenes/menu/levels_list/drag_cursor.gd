extends Area2D

export var sorting_path: NodePath
onready var sorting: Node = get_node(sorting_path)

export var list_handler_path: NodePath
onready var list_handler: Node = get_node(list_handler_path)

var current_card: Button
var decoration: Control

func start_dragging(card: Button):
	if is_instance_valid(current_card): return
	
	$CollisionShape2D.disabled = false
	
	current_card = card
	current_card.modulate.a = 0
	
	decoration = current_card.get_node("Decoration").duplicate()
	decoration.modulate.a = 0.75
	decoration.rect_position = card.rect_global_position - get_viewport().get_mouse_position()
	add_child(decoration)


func stop_dragging(card: Button):
	if not is_instance_valid(current_card): return
	if not card == current_card: return
	
	$CollisionShape2D.disabled = true
	
	current_card.modulate.a = 1
	current_card = null
	
	decoration.queue_free()
	decoration = null
	
	sorting.save_to_json(list_handler.working_folder)


func _process(delta):
	if not is_instance_valid(current_card): return
	position = get_viewport().get_mouse_position()


func _area_entered(area):
	if not is_instance_valid(current_card): return
	
	var intersecting_card: Button = area.get_parent()
	if intersecting_card == current_card: return
	
	var level_grid: GridContainer = current_card.get_parent()
	var new_index: int = intersecting_card.get_index()
	level_grid.move_child(current_card, new_index)
	
	var saved_index: int = new_index
	saved_index -= sorting.sort.folders.size()
	if list_handler.folder_stack.size() > 1:
		saved_index -= 1
		print("back button present!")
	
	var level_id = current_card.name
	if level_id in sorting.sort.levels:
		sorting.sort.levels.erase(level_id)
		sorting.sort.levels.insert(saved_index, level_id)
