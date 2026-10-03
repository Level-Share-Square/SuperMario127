extends MarginContainer

onready var level_name = get_node("%Level Name")
onready var author = get_node("%Author")
onready var description = get_node("%Description")
onready var thumbnail = $"%Thumbnail"
onready var aspect_container = $"%AspectContainer"
onready var thumbnail_url = get_node("%ThumbnailURL")
onready var foreground = $"%Foreground"
onready var window = owner

func _ready() -> void:
	var thumb_size = thumbnail.texture.get_size()
	aspect_container.ratio = thumb_size.x/thumb_size.y
	level_name.connect("text_changed", self, "on_level_name_changed")
	author.connect("text_changed", self, "on_author_changed")
	description.connect("text_changed", self, "on_description_changed")
	thumbnail_url.connect("text_changed", self, "on_thumbnail_changed")

func update_level_info():
	CurrentLevelData.level_metadata.level_name = level_name.text
	CurrentLevelData.level_metadata.level_author = author.text
	CurrentLevelData.level_metadata.level_description = description.text
	CurrentLevelData.level_metadata.level_thumbnail_url = thumbnail_url.text
	update_thumb_texture(thumbnail_url.text)
		
		
func on_level_name_changed(new_text):
	update_level_info()
	
func on_author_changed(new_text):
	update_level_info()
	
func on_description_changed():
	update_level_info()
	
func on_thumbnail_changed(new_text):
	update_level_info()

func update_thumb_texture(new_thumbnail_url):
	var new_thumbnail: ImageTexture = yield(AssetHandler.load_image(new_thumbnail_url, CurrentLevelData.working_folder), "completed")
	if new_thumbnail:
		thumbnail.texture = new_thumbnail
		foreground.hide()
	else:
		thumbnail.texture = CurrentLevelData.level_metadata.get_level_background_texture()
		foreground.texture = CurrentLevelData.level_metadata.get_level_foreground_texture()
		foreground.modulate = CurrentLevelData.level_metadata.get_level_background_modulate()
		foreground.show()
