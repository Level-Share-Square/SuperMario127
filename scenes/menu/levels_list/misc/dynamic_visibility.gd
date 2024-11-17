extends Control

export (Array, String) var visible_screens

onready var subscreens := $"%Subscreens"
onready var list_handler := $"%ListHandler"

const TWEEN_TIME: float = 0.25
onready var tween := $Tween


func _ready():
	yield(list_handler, "ready")
	
	subscreens.connect("screen_changed", self, "update_buttons")
	list_handler.connect("directory_changed", self, "update_buttons")


func update_buttons(path: String = ""):
	var is_visible: bool = subscreens.get_screen_name() in visible_screens
	var target_alpha: float = 1 if is_visible else 0
	
	if is_visible: 
		set_visible(true)
	else:
		tween.connect("tween_all_completed", self, "set_visible", [false], CONNECT_ONESHOT)
	
	tween.interpolate_property(self, "modulate:a", modulate.a, target_alpha, TWEEN_TIME)
	tween.start()
	
	var is_root_folder = list_handler.working_folder == level_list_util.BASE_FOLDER
	var is_dev_folder = list_handler.working_folder == level_list_util.DEV_FOLDER
	$Back.visible = is_root_folder or is_dev_folder
	$FolderSettings.visible = not is_root_folder and not is_dev_folder
	$Add.visible = not is_dev_folder
