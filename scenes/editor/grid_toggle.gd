extends ParallaxBackground

func _ready():
	$Layer.visible = EditorSavedSettings.show_grid

func _unhandled_input(event):
	if event.is_action_pressed("toggle_grid"):
		$Layer.visible = !$Layer.visible
		EditorSavedSettings.show_grid = $Layer.visible
