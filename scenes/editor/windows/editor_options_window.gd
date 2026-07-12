extends EditorWindow

var level_name
var author
var description
var thumbnail_url

signal open_editor_settings


func on_editor_settings_pressed():
	hide()
	emit_signal("open_editor_settings")

func update_background():
	owner.backgrounds.update_background_area(CurrentLevelData.level_data.areas[CurrentLevelData.area])
