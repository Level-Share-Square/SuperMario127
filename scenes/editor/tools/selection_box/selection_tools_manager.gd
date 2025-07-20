extends Control


var active_tool: SelectionTool
onready var move = $"%Move"
onready var rotate = $"%Rotate"
onready var delete = $"%Delete"

onready var pivot_toggle_button = $"%PivotToggleButton"
onready var properties_button = $"%PropertiesButton"
onready var delete_button = $"%DeleteButton"
onready var button_container = $"../EditSelection/ButtonContainer"

onready var editor = get_tree().get_current_scene()
onready var selection_box = get_owner()


func _ready():
	for node in button_container.get_children():
		if node is SelectionToolButton:
			node.connect("button_down", self, "button_pressed", [node])

func _process(delta):
	if is_instance_valid(active_tool):
		active_tool.update()
		
	if active_tool != null and active_tool.is_active == true:
		if Input.is_action_just_released("LMB"):
			selection_box.toggle_ui(true)
			active_tool.commit_to_action()
			active_tool.is_active = false
			active_tool = null

func button_pressed(button: SelectionToolButton):
	if active_tool == button.associated_tool:
		selection_box.toggle_ui(true)
		active_tool.commit_to_action()
		active_tool.is_active = false
		active_tool = null
		return
	
	else:
		selection_box.toggle_ui(false)
		active_tool = button.associated_tool
		active_tool.is_active = true
		active_tool._get_pivot_offset()
		active_tool.clicked()
