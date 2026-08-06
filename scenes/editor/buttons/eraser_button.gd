extends ButtonSound


export var tool_manager_path: NodePath
onready var tool_manager: ToolManager = get_node(tool_manager_path)


func _ready():
	connect("draw", self, "update_button")


func update_button() -> void:
	if pressed != tool_manager.is_erasing:
		set_pressed_no_signal(tool_manager.is_erasing)
