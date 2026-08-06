extends VBoxContainer

onready var editor = get_tree().current_scene

onready var gravity = $"%Gravity"
onready var mins = $"%Mins"
onready var sec = $"%Sec"


func _ready():
	gravity.connect("value_changed", self, "gravity_changed")
	mins.connect("value_changed", self, "time_changed")
	sec.connect("value_changed", self, "time_changed")
	
	yield(editor, "ready")
	editor.action_manager.connect("action", self, "load_settings")
	editor.action_manager.connect("undo", self, "load_settings")
	editor.action_manager.connect("redo", self, "load_settings")
	load_settings()
	
func load_settings():
	var area = CurrentLevelData.current_area
	
	gravity.set_value_no_signal(area.header.gravity)
	mins.set_value_no_signal(int(area.header.timer/60))
	sec.set_value_no_signal(fmod(area.header.timer, 60.0))
	
	gravity.get_line_edit().text = str(gravity.value)
	mins.get_line_edit().text = str(mins.value) + " m"
	sec.get_line_edit().text = str(sec.value) + " s"
	

func gravity_changed(new_value) -> void:
	var action := ChangeAreaAction.new()
	action.property = "gravity"
	action.id = CurrentLevelData.area_id
	action.new_value = new_value
	editor.action_manager.commit_action(action)

func time_changed(new_value) -> void:
	var action := ChangeAreaAction.new()
	action.property = "timer"
	action.id = CurrentLevelData.area_id
	action.new_value = mins.value*60 + sec.value
	editor.action_manager.commit_action(action)
