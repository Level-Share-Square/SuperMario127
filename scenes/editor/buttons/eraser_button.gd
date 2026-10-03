extends ButtonSound


export var tool_manager_path: NodePath
onready var tool_manager: ToolManager = get_node(tool_manager_path)
onready var tween = $Tween


func _ready():
	connect("draw", self, "update_button")
	connect("pressed", self, "update_color")
	update_button()


func update_button(is_erasing: bool = tool_manager.is_erasing) -> void:
	if pressed != is_erasing:
		set_pressed_no_signal(is_erasing)
		update_color(is_erasing)


func update_color(is_erasing: bool = tool_manager.is_erasing) -> void:
	tween.stop_all()
	tween.interpolate_property(
		self,
		"self_modulate",
		self_modulate,
		Color.lightcoral if is_erasing else Color.white,
		0.2,
		Tween.TRANS_CIRC,
		Tween.EASE_OUT
	)
	tween.start()
