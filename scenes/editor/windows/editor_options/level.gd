extends MarginContainer

onready var level_name = get_node("%Level Name")
onready var author = get_node("%Author")
onready var description = get_node("%Description")
onready var thumbnail = $"%Thumbnail"
onready var aspect_container = $"%AspectContainer"
onready var thumbnail_url = get_node("%Thumbnail URL")
onready var window = owner


func _ready() -> void:
	var thumb_size = thumbnail.texture.get_size()
	aspect_container.ratio = thumb_size.x/thumb_size.y
