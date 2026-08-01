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
onready var reset_autosaves = $"%ResetAutosaves"

func _ready():
	for interval_name in intervals.values():
		interval_options.add_item(interval_name)
	interval_options._select_int(intervals.keys().find(EditorState.autosave_interval))
	load_autosave_buttons()
	reset_autosaves.connect("button_down", self, "on_reset_pressed")
	EditorState.connect("autosave", self, "autosave")
	
func load_autosaves() -> Array:
	var autosaves: Array = []
	var dir: Directory = Directory.new()
	if !dir.dir_exists(AUTOSAVE_FOLDER):
		dir.make_dir_recursive(AUTOSAVE_FOLDER)
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
				if autosaved_id == CurrentLevelData.level_id:
					autosaves.append(time)
				elif autosaved_id == CurrentLevelData.level_metadata.level_name:
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
	var file = File.new()
	file.open(AUTOSAVE_FOLDER + "%s_%s" % [level_id, time], File.READ)
	level_code = file.get_line()
	file.close()
	

	CurrentLevelData.load_level_headers(level_code)
	CurrentLevelData.switch_to_area(CurrentLevelData.area_id)

	SceneTransitions.reload_scene()

func autosave():
	var time = Time.get_unix_time_from_system()
	var file_name: String = "%s_%s" % [CurrentLevelData.level_id, round(time)]
	
	var file := File.new()
	file.open(AUTOSAVE_FOLDER + file_name, File.WRITE)
	for area_id in CurrentLevelData.loaded_areas:
		# should probably put this in CurrentLevelData
		CurrentLevelData.area_headers[area_id].area_code = LevelCodeSerializer.serialize_area(CurrentLevelData.loaded_areas[area_id])
	
	var container: LevelDataContainer = LevelDataContainer.new(CurrentLevelData.level_metadata, CurrentLevelData.editor_data, CurrentLevelData.area_headers)
	LevelCodeHandler.recalculate_level_collectible_counts(container)
	var level_code: String = LevelCodeSerializer.serialize_level_data(container)

	file.store_string(level_code)
	file.close()

	load_autosave_buttons()


func interval_selected(index):
	var interval = intervals.keys()[index]
	EditorState.set_interval(interval)
	LocalSettings.change_setting("General", "autosave_interval", interval)

func on_reset_pressed():
	var dir: Directory = Directory.new()
	if !dir.dir_exists(AUTOSAVE_FOLDER):
		dir.make_dir_recursive(AUTOSAVE_FOLDER)
		return
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
				if autosaved_id == CurrentLevelData.level_id:
					dir.remove(AUTOSAVE_FOLDER + "/" + file_name)
	load_autosave_buttons()

func load_autosave_buttons():
	for child in saves_container.get_children():
		child.disconnect("button_down", self, "open_autosave")
		child.queue_free()
	for autosave in load_autosaves():
		var button = Button.new()
		button.text = Time.get_datetime_string_from_unix_time(int(autosave), true)
		button.focus_mode = Control.FOCUS_NONE
		button.connect("button_down", self, "open_autosave", [autosave])
		saves_container.add_child(button)
