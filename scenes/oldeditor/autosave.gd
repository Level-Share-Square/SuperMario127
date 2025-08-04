class_name Autosave
extends Node

const AUTOSAVE_FOLDER = "user://autosaves/"

var intervals: Dictionary = {
	-1: "Never",
	300: "5 Minutes",
	900: "15 Minutes",
	1800: "30 Minutes",
	3600: "1 Hour"
}

var interval: int = 900
var timer: float = 0

signal autosaved

func _ready():
	timer = LocalSettings.load_setting("General", "autosave_interval", 900)
	
func _physics_process(delta):
	if timer > 0:
		timer -= delta
	elif timer != -1:
		autosave()
		timer = interval

func autosave():
	var file_name: String = "%s_%s" % [Singleton.CurrentLevelData.level_id, round(Time.get_unix_time_from_system())]
	
	var file := File.new()
	file.open(AUTOSAVE_FOLDER + file_name, File.WRITE)
	file.store_string(Singleton.CurrentLevelData.level_data.get_encoded_level_data())
	file.close()
	emit_signal("autosaved")
