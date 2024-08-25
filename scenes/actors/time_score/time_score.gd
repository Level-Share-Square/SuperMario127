extends CanvasLayer

onready var label : Label = $TimeScore

var shown = false

func _process(_delta) -> void:
	var current_scene = get_tree().get_current_scene()
	if "mode" in current_scene and !Singleton.PhotoMode.enabled:
		label.visible = (shown and current_scene.mode == 0 and Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible)
	else:
		label.visible = false
	
	if label.visible:
		_update_time_display()

func _update_time_display() -> void:
	label.text = LevelInfo.generate_time_string(Singleton.CurrentLevelData.time_score)
