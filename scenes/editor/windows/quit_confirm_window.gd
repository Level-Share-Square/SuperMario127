extends EditorWindow


onready var editor: Editor = owner


func _on_Countdown_pressed():
	CurrentLevelData.unsaved_editor_changes = false
	editor.save_manager.quit()
