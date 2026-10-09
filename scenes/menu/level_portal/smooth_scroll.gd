extends ScrollContainer

signal next_page

const SNAP_THRESHOLD: float = 0.1
const LERP_THRESHOLD: float = 8.0
export var lerp_speed: float

var target_scroll: float = -1
var last_scroll: float
var smoothing: bool = true

# hacky code but i really dont want to care rn ,, 
export var page_loading: bool
var child: Node

func _process(delta):
	if smoothing and abs(last_scroll - scroll_vertical) > LERP_THRESHOLD:
		target_scroll = scroll_vertical
		scroll_vertical = last_scroll
	
	if target_scroll > -1:
		scroll_vertical = lerp(scroll_vertical, target_scroll, delta * lerp_speed)
		if abs(target_scroll - scroll_vertical) < SNAP_THRESHOLD:
			scroll_vertical = target_scroll
			target_scroll = -1
	
	if page_loading:
		if not is_instance_valid(child):
			child = get_child(0)
		
		var destination: float = target_scroll if target_scroll > -1 else float(scroll_vertical)
		if destination != last_scroll and destination > child.rect_size.y - rect_size.y - 32:
			emit_signal("next_page")
	
	last_scroll = scroll_vertical


func _ready():
	follow_focus = false
	get_viewport().connect("gui_focus_changed", self, "gui_focus_changed")
	get_tree().connect("node_added", self, "pass_touch")
	pass_touch(self)


func pass_touch(node: Node) -> void:
	if node is Control and node.mouse_filter == MOUSE_FILTER_STOP and is_a_parent_of(node) \
			and not (node is Range or node is TextEdit):
		node.mouse_filter = MOUSE_FILTER_PASS
	for child in node.get_children():
		pass_touch(child)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		smoothing = false
		target_scroll = -1
	elif event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion \
			or (event is InputEventMouseButton and event.button_index in [BUTTON_WHEEL_UP, BUTTON_WHEEL_DOWN]):
		smoothing = true


export var custom_follow_focus: bool
func gui_focus_changed(control: Control):
	if not custom_follow_focus: return
	if not is_visible_in_tree(): return
	if LastInputDevice.is_mouse: return
	if not is_a_parent_of(control): return
	
	scroll_vertical = (control.rect_position.y + control.rect_size.y) - rect_size.y/2
