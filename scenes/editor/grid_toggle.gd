extends ParallaxBackground

func _ready():
	$Layer.visible = Singleton.EditorSavedSettings.show_grid
	$Layer/TextureRect.texture = preload("res://scenes/editor/assets/grid2.png")
	# for some reason loading the texture in scripts fixes the issue

func _unhandled_input(event):
	if Singleton2.disable_hotkeys == false:
		if event.is_action_pressed("toggle_grid"):
			$Layer.visible = !$Layer.visible
			Singleton.EditorSavedSettings.show_grid = $Layer.visible
