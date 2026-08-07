extends Control


var active_tool: SelectionTool
onready var move = $"%Move"
onready var rotate = $"%Rotate"
onready var delete = $"%Delete"
onready var align = $"%Align"

onready var pivot_toggle_button = $"%PivotToggleButton"
onready var properties_button = $"%PropertiesButton"
onready var delete_button = $"%DeleteButton"
onready var button_container = $"%ButtonContainer"

onready var editor = get_tree().get_current_scene()
onready var selection_box = get_owner()

var active_tool_hotkey: String

func _ready():
	for node in button_container.get_children():
		if node is SelectionToolButton:
			node.connect("button_down", self, "button_pressed", [node])
	properties_button.connect("pressed", self, "properties_pressed")

func start_tool_hotkey(action_name: String):
	active_tool_hotkey = action_name
	match action_name:
		"rotate_object":
			button_pressed(get_node("%RotateSelection"))
		"scale_object":
			button_pressed(get_node("%ScaleSelection"))

func _process(delta):
	if is_instance_valid(active_tool):
		active_tool.update()
		
	if active_tool != null and active_tool.is_active == true:
		if Input.is_action_just_released("click") or (active_tool_hotkey and Input.is_action_just_released(active_tool_hotkey)):
			selection_box.toggle_ui(true)
			active_tool.commit_to_action()
			active_tool.is_active = false
			active_tool = null
			active_tool_hotkey = ""
	align.rect_scale = editor.get_node("EditorCamera").zoom

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
		active_tool.clicked()

func properties_pressed():
	editor.open_object_properties(editor.selected_objects)
