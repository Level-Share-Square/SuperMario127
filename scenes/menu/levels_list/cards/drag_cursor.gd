extends Area2D

var sort: Dictionary

onready var list_handler = $"%ListHandler"
onready var level_grid = $"%LevelGrid"

var current_card: BaseCard
var decoration: Control


func start_dragging(card: Button):
	if is_instance_valid(current_card): return
	
	$CollisionShape2D.disabled = false
	
	current_card = card
	current_card.modulate.a = 0
	
	decoration = current_card.get_node("Decoration").duplicate()
	decoration.modulate.a = 0.75
	decoration.rect_position = card.rect_global_position - get_viewport().get_mouse_position()
	
	decoration.set_script(null)
	add_child(decoration)


func stop_dragging(card: Button):
	if not is_instance_valid(current_card): return
	if not card == current_card: return
	
	$CollisionShape2D.disabled = true
	
	current_card.modulate.a = 1
	current_card = null
	
	decoration.call_deferred("queue_free")
	decoration = null


func _process(delta):
	if not is_instance_valid(current_card): return
	position = get_viewport().get_mouse_position()


func _area_entered(area):
	if not is_instance_valid(current_card): return
	
	var intersecting_card: Button = area.get_parent()
	var new_index: int = intersecting_card.get_index()
	
	current_card.drag_index = new_index
	current_card.change_index(new_index)
