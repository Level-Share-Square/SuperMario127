extends HBoxContainer
class_name AreaBoundsEditor

enum ChangeType {ADD, SUBTRACT}

const X_LABEL_PREFIX: String = "X: %d"
const Y_LABEL_PREFIX: String = "Y: %d"

onready var top = $"%Top"
onready var left = $"%Left"
onready var x_label = $"%XLabel"
onready var y_label = $"%YLabel"
onready var right = $"%Right"
onready var bottom = $"%Bottom"
onready var increment = $"%Increment"

onready var editor = get_tree().current_scene
onready var shared = editor.get_shared_node()
onready var camera = editor.get_node("%EditorCamera")

var area_rect: Rect2
var area: AreaData

func _ready():
	var containers = [top, left, right, bottom]
	for container in containers:
		container.get_node("Add").connect("pressed", self, "change_bounds", [container.name.to_lower(), ChangeType.ADD])
		container.get_node("Subtract").connect("pressed", self, "change_bounds", [container.name.to_lower(), ChangeType.SUBTRACT])
		
	area = CurrentLevelData.current_area
	area_rect = area.header.bounds
	
	yield(editor, "ready")
	editor.action_manager.connect("action", self, "update_values", [false])
	editor.action_manager.connect("undo", self, "update_values", [false])
	editor.action_manager.connect("redo", self, "update_values", [false])
	
	increment.value = CurrentLevelData.editor_data.area_bounds_increment
	update_values(true)
	
func change_bounds(side: String, type: int):
	var amount = increment.value
	if type == ChangeType.SUBTRACT: amount *= -1
	
	area_rect = area.header.bounds
	var orig_end: Vector2 = area_rect.end
	
	match side:
		"top":
			var new_top = min(area_rect.position.y - amount, orig_end.y - 14)
			area_rect.position.y = new_top
			area_rect.size.y = orig_end.y - new_top
			
		"left":
			var new_left = min(area_rect.position.x - amount, orig_end.x - 24)
			area_rect.position.x = new_left
			area_rect.size.x = orig_end.x - new_left
			
		"right":
			area_rect.size.x = max(24, area_rect.size.x + amount)
			
		"bottom":
			area_rect.size.y = max(14, area_rect.size.y + amount)
			
	action()
	
	update_values(true)
	
func action() -> void:
	var action := ChangeAreaAction.new()
	action.property = "bounds"
	action.id = CurrentLevelData.area_id
	action.shared = editor.get_shared_node()
	action.new_value = area_rect
	editor.action_manager.commit_action([action])
	
	CurrentLevelData.editor_data.area_bounds_increment = increment.value

func update_values(bypass_checks: bool = false):
	if !bypass_checks:
		var update_values: bool = false
		var actions: Array = [editor.action_manager.undo_stack.back(), editor.action_manager.redo_stack.back()]
		for action_array in actions:
			if not action_array: continue
			for action in action_array:
				if action is ChangeAreaAction and action.property == "bounds":
					update_values = true
					break
		if !update_values: return

	shared.update_tilemaps()
	camera.update_limits(area.header)
	editor.oob_overlay.set_bounds(Rect2(area.header.bounds.position*32, area.header.bounds.size*32))
	area_rect = area.header.bounds
	x_label.text = X_LABEL_PREFIX % area_rect.size.x
	y_label.text = Y_LABEL_PREFIX % area_rect.size.y
