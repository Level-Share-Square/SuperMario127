extends EditorWindow

onready var level_name = $"%Level Name"
onready var author = $"%Author"
onready var description = $"%Description"
onready var thumbnail_url = $"%ThumbnailURL"

signal open_editor_settings

func _ready():
	level_name.text = CurrentLevelData.level_metadata.level_name
	author.text = CurrentLevelData.level_metadata.level_author
	description.text = CurrentLevelData.level_metadata.level_description
	thumbnail_url.text = CurrentLevelData.level_metadata.level_thumbnail_url 

func on_editor_settings_pressed():
	hide()
	emit_signal("open_editor_settings")

func update_background():
	owner.backgrounds.update_background_area(CurrentLevelData.area.header)

func update_level_info():
	CurrentLevelData.level_metadata.level_name = level_name.text
	CurrentLevelData.level_metadata.level_author = author.text
	CurrentLevelData.level_metadata.level_description = description.text
	CurrentLevelData.level_metadata.level_thumbnail_url = thumbnail_url.text
