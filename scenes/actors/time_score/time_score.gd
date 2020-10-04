extends CanvasLayer

onready var label : Label = $TimeScore
onready var label_shadow : Label = $TimeScore/Shadow

var shown = false

func _process(_delta) -> void:
	var current_scene = get_tree().get_current_scene()
	if "mode" in current_scene and !PhotoMode.enabled:
		label.visible = (shown and current_scene.mode == 0 and mode_switcher.get_node("ModeSwitcherButton").invisible)
	else:
		label.visible = false
	
	if label.visible:
		_update_time_display()

func _update_time_display() -> void:
	label.text = LevelInfo.generate_time_string(CurrentLevelData.time_score)
	label_shadow.text = label.text
