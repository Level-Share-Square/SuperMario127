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

onready var interval_options: OptionButton = $"%IntervalOptions"
onready var saves_container = $"%SavesContainer"

var interval: int = 900
var timer: float = 0

signal autosaved

func _ready():
	interval = LocalSettings.load_setting("General", "autosave_interval", 900)
	for interval_name in intervals.values():
		interval_options.add_item(interval_name)
	interval_options._select_int(intervals.keys().find(interval))
	timer = interval
	for autosave in load_autosaves():
		var button = Button.new()
		button.text = Time.get_datetime_string_from_unix_time(int(autosave), true)
		button.focus_mode = Control.FOCUS_NONE
		button.connect("button_down", self, "open_autosave", [autosave])
		saves_container.add_child(button)
	
func load_autosaves() -> Array:
	var level_id = CurrentLevelData.level_id
	var level_name = CurrentLevelData.level_info.level_name
	
	var autosaves: Array = []
	var dir: Directory = Directory.new()
	dir.open(AUTOSAVE_FOLDER)
	dir.list_dir_begin(true, true)
	
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		else:
			var split = file_name.split("_")
			
			if split.size() > 1:
				var autosaved_id = split[0]
				var time = split[1]
				if autosaved_id == level_id:
					autosaves.append(time)
				elif autosaved_id == level_name:
					if not dir.dir_exists("old_autosaves"):
						dir.make_dir("old_autosaves")
					
					dir.rename(file_name, "old_autosaves/%s" % file_name)
			else:
				if file_name == "settings.file":
					dir.remove("settings.file")
	
	dir.list_dir_end()
	return autosaves
	
func open_autosave(time):
	var level_id = CurrentLevelData.level_id
	var level_code: String
	var working_folder = CurrentLevelData.working_folder
	var file = File.new()
	file.open(AUTOSAVE_FOLDER + "%s_%s" % [level_id, time], File.READ)
	level_code = file.get_line()
	file.close()
	
	var level_info := LevelInfo.new(level_id, working_folder, level_code)
	level_info.load_in()
	CurrentLevelData.level_data = level_info.level_data
	Singleton.SceneTransitions.reload_scene()
	
func _physics_process(delta):
	if timer > 0:
		timer -= delta
	elif timer != -1:
		autosave()
		timer = interval

func autosave():
	var file_name: String = "%s_%s" % [CurrentLevelData.level_id, round(Time.get_unix_time_from_system())]
	
	var file := File.new()
	file.open(AUTOSAVE_FOLDER + file_name, File.WRITE)
	file.store_string(CurrentLevelData.level_data.get_encoded_level_data())
	file.close()
	emit_signal("autosaved")


func interval_selected(index):
	interval = intervals.keys()[index]
	LocalSettings.change_setting("General", "autosave_interval", interval)
	timer = interval
