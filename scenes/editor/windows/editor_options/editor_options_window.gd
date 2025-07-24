extends EditorWindow

onready var level_name = $"%Level Name"
onready var author = $"%Author"
onready var description = $"%Description"
onready var thumbnail_url = $"%ThumbnailURL"

signal open_editor_settings


func on_editor_settings_pressed():
	hide()
	emit_signal("open_editor_settings")

func update_background():
	owner.backgrounds.update_background_area(Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area])
