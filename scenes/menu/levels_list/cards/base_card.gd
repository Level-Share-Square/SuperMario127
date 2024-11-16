class_name BaseCard
extends ButtonHoverRotate

onready var parent: GridContainer = get_parent()
onready var decoration = $Decoration
var sort: Dictionary

# srry but child classes will need to set these in their setup func :p
## passed nodes
var list_handler: LevelListHandler
var drag_cursor: Area2D

## parameters
var id: String
var parent_folder: String
var sort_type: String
var can_sort: bool
var move_to_front: bool


func _enter_tree():
	connect("mouse_drag_started", drag_cursor, "start_dragging")
	connect("mouse_drag_ended", drag_cursor, "stop_dragging")
	if move_to_front:
		var sort: Dictionary = sort_file_util.load_sort_file(parent_folder)
		var start_index: int = sort_file_util.get_start_index_with_back(sort, sort_type, parent_folder)
		get_parent().move_child(self, start_index)


## dragging
signal mouse_drag_started(card)
signal mouse_drag_ended(card)
signal button_pressed

const DRAG_HOLD_TIME = 0.125

var is_mouse: bool
var button_down: bool
var hold_time: float
var drag_index: int


func _input(event):
	if not can_sort or not button_down: return
	
	var direction: Vector2
	if event.is_action_pressed("ui_left"): direction.x -= 1
	if event.is_action_pressed("ui_right"): direction.x += 1
	if event.is_action_pressed("ui_up"): direction.y -= 1
	if event.is_action_pressed("ui_down"): direction.y += 1
	
	if direction != Vector2.ZERO:
		var new_index: int = drag_index + direction.x
		if (
			(direction.y > 0 and drag_index < parent.get_child_count() - parent.columns) or 
			(direction.y < 0 and drag_index > parent.columns)
		):
			new_index += direction.y * parent.columns
		
		drag_index = new_index
		
		var sort: Dictionary = sort_file_util.load_sort_file(parent_folder)
		var start_index: int = sort_file_util.get_start_index_with_back(sort, sort_type, parent_folder)
		drag_index = clamp(drag_index,
			0,
			sort_file_util.get_category_size(sort, sort_type) + start_index - 1
		)
		
		change_index(new_index)
		get_tree().set_input_as_handled()


func change_index(new_index: int):
	var sort: Dictionary = sort_file_util.load_sort_file(parent_folder)
	var start_index: int = sort_file_util.get_start_index_with_back(sort, sort_type, parent_folder)
	
	new_index = max(0, new_index)
	if new_index < start_index:
		var new_parent: BaseCard = parent.get_child(new_index)
		decoration.rect_global_position = new_parent.rect_global_position
	else:
		decoration.rect_position = Vector2.ZERO
	
	new_index = clamp(new_index, 
		start_index, 
		sort_file_util.get_category_size(sort, sort_type) + start_index - 1
	)
	parent.move_child(self, new_index)


func _process(delta):
	if button_down and hold_time < DRAG_HOLD_TIME:
		hold_time += delta
		if hold_time >= DRAG_HOLD_TIME:
			decoration.modulate.a = 0.75
			if Input.is_mouse_button_pressed(BUTTON_LEFT):
				is_mouse = true
				emit_signal("mouse_drag_started", self)


func button_down():
	if not can_sort: return
	button_down = true
	drag_index = get_index()
	hold_time = 0


func button_up():
	if not can_sort:
		list_handler.change_focus(self)
		emit_signal("button_pressed")
		return
	
	button_down = false
	if hold_time >= DRAG_HOLD_TIME:
		drag_over()
		if is_mouse:
			emit_signal("mouse_drag_ended", self)
	else:
		list_handler.change_focus(self)
		emit_signal("button_pressed")


func drag_over():
	var sort: Dictionary = sort_file_util.load_sort_file(parent_folder)
	var start_index: int = sort_file_util.get_start_index_with_back(sort, sort_type, parent_folder)
	
	if drag_index < start_index:
		var parent_card: BaseCard = parent.get_child(drag_index)
		if parent_card.has_method("card_dragged"):
			parent_card.card_dragged(self)
	else:
		sort.get_or_add(sort_type).erase(id)
		sort.get_or_add(sort_type).insert(drag_index - start_index, id)
		sort_file_util.save_sort_file(parent_folder, sort)
	
	drag_index = get_index()
	decoration.modulate.a = 1
	decoration.rect_position = Vector2.ZERO
