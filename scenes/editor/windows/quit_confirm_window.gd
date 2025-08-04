extends EditorWindow


onready var editor: Editor = owner


func _on_Countdown_pressed():
	editor.save_manager.unsaved_changes = false
	editor.save_manager.quit()
