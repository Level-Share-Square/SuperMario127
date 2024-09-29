extends Control

export (Array, String) var visible_screens

export var subscreens_path: NodePath
onready var subscreens: Control = get_node(subscreens_path)

export var list_handler_path: NodePath
onready var list_handler: Node = get_node(list_handler_path)

const TWEEN_TIME: float = 0.25
onready var tween := $Tween

func _ready():
	yield(list_handler, "ready")
	
	subscreens.connect("screen_changed", self, "update_buttons")
	list_handler.folders.connect("folder_changed", self, "update_buttons")

func update_buttons(path: String = ""):
	var is_visible: bool = subscreens.get_screen_name() in visible_screens
	var target_alpha: float = 1 if is_visible else 0
	
	if is_visible: 
		set_visible(true)
	else:
		tween.connect("tween_all_completed", self, "set_visible", [false], CONNECT_ONESHOT)
	
	tween.interpolate_property(self, "modulate:a", modulate.a, target_alpha, TWEEN_TIME)
	tween.start()
	
	var is_root_folder = (list_handler.working_folder == list_handler.BASE_FOLDER)
	$Back.visible = is_root_folder
	$FolderSettings.visible = !is_root_folder
