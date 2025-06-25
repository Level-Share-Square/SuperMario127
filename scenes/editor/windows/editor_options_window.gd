extends EditorWindow


signal open_editor_settings


func on_editor_settings_pressed():
	hide()
	emit_signal("open_editor_settings")
