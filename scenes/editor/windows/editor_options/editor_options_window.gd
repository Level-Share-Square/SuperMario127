extends EditorWindow

onready var level_name = $"%Level Name"
onready var author = $"%Author"
onready var description = $"%Description"
onready var thumbnail_url = $"%ThumbnailURL"
onready var thumbnail = $"%Thumbnail"

signal open_editor_settings

func _ready():
	level_name.text = CurrentLevelData.level_metadata.level_name
	author.text = CurrentLevelData.level_metadata.level_author
	description.text = CurrentLevelData.level_metadata.level_description
	thumbnail_url.text = CurrentLevelData.level_metadata.level_thumbnail_url 
	var new_thumbnail: ImageTexture = yield(AssetHandler.load_image(thumbnail_url.text, CurrentLevelData.working_folder), "completed")
	if new_thumbnail:
		thumbnail.texture = new_thumbnail
func on_editor_settings_pressed():
	hide()
	emit_signal("open_editor_settings")

func update_background():
	owner.backgrounds.update_background_area(CurrentLevelData.current_area.header)
