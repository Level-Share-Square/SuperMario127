class_name Selector
extends EditorTool

const TILE_SIZE: int = 32
const TILE := Vector2(TILE_SIZE, TILE_SIZE)

export var animation_delay: float = 6
export var frame_count: int = 5

onready var parallax_scroll = $"%ParallaxScroll"
onready var debug = $"%Debug"
onready var highlight = get_node("%Highlight")
onready var selection_box = get_node("%SelectionBox")
onready var camera = $"%EditorCamera"

var is_dragging: bool = false
var pasted: bool = false

var fill_rect: Rect2
var start_pos: Vector2
var mouse_pos: Vector2
var timer = 0

signal mouse_motion(position)

func _ready():
	highlight.hide()
	selection_box.hide()
	
	yield(editor, "ready")
	editor.tool_manager.connect("tool_changed", self, "on_tool_changed")
	
	remove_child(debug)
	editor.add_child(debug)

func get_tile_grid_position(vector: Vector2):
	return vector.snapped(TILE) / TILE_SIZE
	
func get_mouse_grid_position():
	return get_tile_grid_position(get_mouse_pos())
	
func get_adjusted_mouse_position():
	return get_mouse_pos().snapped(TILE)
	
func _click_left(event, mouse_position):
	var adjusted_mouse_position = get_adjusted_mouse_position()
	on_mouse_clicked()
	if !fill_rect.has_point(adjusted_mouse_position):
		is_dragging = true
		set_highlight_mode(true)
		reset_bounds()
		start_pos = adjusted_mouse_position
		on_selection_outside_clicked()
	else:
		on_selection_inside_clicked()
		
func _click_left_released(event, mouse_position):
	is_dragging = false
	emit_signal("mouse_motion", null)
	set_highlight_mode(false)
	on_mouse_released()
	
func _mouse_movement(event, mouse_position):
	var adjusted_mouse_position = get_adjusted_mouse_position()
	if mouse_pos != adjusted_mouse_position:
		emit_signal("mouse_motion", adjusted_mouse_position)
		mouse_pos = adjusted_mouse_position
	if is_dragging:
		box_expansion()
			
func set_highlight_mode(value: bool):
	highlight.visible = value
	selection_box.visible = !value
	
func hide_visuals():
	highlight.visible = false
	selection_box.visible = false
	
func reset_bounds():
	highlight.rect_global_position = Vector2.ZERO
	highlight.rect_size = Vector2.ZERO
	selection_box.rect_global_position = Vector2.ZERO
	selection_box.rect_size = Vector2.ZERO
	fill_rect = Rect2(0, 0, 0, 0)

func _process(delta):
	timer = max(timer - 1, 0)

	if timer <= 0:
		selection_box.region_rect.position.x = wrapi(
			selection_box.region_rect.position.x + selection_box.region_rect.size.x,
			0,
			frame_count * selection_box.region_rect.size.x
		)
		timer = animation_delay

func box_expansion():
	var layer = shared.get_layer(editor.layer)
	
	var mouse_pos: Vector2 = get_adjusted_mouse_position()
	var drag_rect := Rect2(start_pos, mouse_pos - start_pos).abs()
	
	fill_rect = drag_rect
	if layer is LevelParallaxLayer:
		drag_rect = layer.parallax_scroll.get_global_transform().xform(drag_rect)
		drag_rect.size /= layer.parallax_scroll.scale
	
	highlight.rect_global_position = drag_rect.position
	highlight.rect_size = drag_rect.size
	
	selection_box.rect_global_position = drag_rect.position
	selection_box.rect_size = drag_rect.size
# Callbacks

func on_selection_inside_clicked():
	pass
	
func on_selection_outside_clicked():
	pass
	
func on_mouse_move():
	pass
	
func on_mouse_clicked():
	pass
	
func on_mouse_released():
	if min(fill_rect.size.x, fill_rect.size.y) < TILE_SIZE:
		reset_bounds()
		hide_visuals()
		return false
	return true
	
func on_tool_changed():
	reset_bounds()
	hide_visuals()
