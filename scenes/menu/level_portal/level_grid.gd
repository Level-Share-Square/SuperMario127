extends GridContainer


onready var level_list = $"%LevelList"
onready var http_level_page = $"%HTTPLevelPage"
onready var http_images = $"%HTTPImages"


const LEVEL_BUTTON: PackedScene = preload("res://scenes/menu/level_portal/level_button/level_button.tscn")


func clear_children():
	for child in get_children():
		child.call_deferred("queue_free")


func add_level(level_info: LSSLevelInfo, thumbnail: ImageTexture = null):
	var level_button: Button = LEVEL_BUTTON.instance()
	
	var styling: Node = level_button.get_node("%Styling")
	styling.level_info = level_info
	styling.texture = thumbnail
	http_images.connect("image_loaded", styling, "thumbnail_loaded")
	
	level_button.connect("pressed", level_list, "transition", [""])
	level_button.connect("pressed", http_level_page, "load_level", [level_info.level_id])
	call_deferred("add_child", level_button)
