extends Control

onready var level_name_label = $VBoxContainer/LevelName
onready var shine_progress = $ShineProgressPanel/HBoxContainer2/ShineProgressLabel
onready var star_coin_progress = $StarCoinProgressPanel/HBoxContainer3/StarCoinProgressLabel
onready var level_sky_thumbnail = $PanelContainer/ThumbnailImage
onready var level_foreground_thumbnail = $PanelContainer/ForegroundThumbnailImage
onready var date = $VBoxContainer/Date
onready var clear = $ClearButton

var main_level_code
var main_time

var active_level_code
var active_time

var codes = []
var times = []

var selector = {}

onready var load_level = $LoadButton

var time_created
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	clear.connect("button_down", self, "on_clear_pressed")
	load_level.connect("button_down", self, "load_level")
	date.connect("item_selected", self, "item_selected")
	var file = File.new()
	$"../LevelName".hide()
	show()
	if file.file_exists("user://autosave/" + LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data()).level_name + "_main.autosave"):
		file.open("user://autosave/" + LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data()).level_name + "_main.autosave", File.READ)
		var time = file.get_line()
		var code = file.get_line()
		var json = parse_json(code)
#		var prin = level_info.load_from_dictionary(code)
		print(json)
		main_level_code = json["level_code"]
		populate_info_panel(LevelInfo.new(main_level_code))
		main_time = float(time)
		date.add_item(Time.get_datetime_string_from_unix_time(main_time, true) + " (Main)")
		file.close()
	else:
		hide()
		$"../LevelName".show()
	
	for i in list_files_in_directory("user://autosave"):
		print(i)
		file.open("user://autosave/" + i, File.READ)
		var time = file.get_line() 
		var code = file.get_line()
		var json = parse_json(code)
		codes.append(json["level_code"])
		times.append(float(time))
		print(times.size())
		print(codes.size())
		
	for i in times:
		date.add_item(Time.get_datetime_string_from_unix_time(i, true))
		
func item_selected(index):
	if index == 0:
		active_level_code = main_level_code
	else:
		active_level_code = codes[index - 1]
	populate_info_panel(LevelInfo.new(active_level_code))

func populate_info_panel(level_info : LevelInfo = null) -> void:
	if level_info != null:
		level_name_label.text = level_info.level_name

		# Only count shine sprites that have show_in_menu on
		var total_shine_count := 0
		var collected_shine_count := 0

		for shine_details in level_info.shine_details:
			total_shine_count += 1
			if level_info.collected_shines[str(shine_details["id"])]:
				collected_shine_count += 1

		shine_progress.text = String(total_shine_count)

		var collected_star_coin_count = level_info.collected_star_coins.values().count(true)
		star_coin_progress.text = String(level_info.collected_star_coins.size())
		
		# set the little thumbnail to look just like the actual level background
		level_sky_thumbnail.texture = level_info.get_level_background_texture()
		level_foreground_thumbnail.modulate = level_info.get_level_background_modulate()
		level_foreground_thumbnail.texture = level_info.get_level_foreground_texture()
		
func load_level():
	get_parent().close()
	get_parent().visible = false
	Singleton2.disable_hotkeys = false
	Singleton.CurrentLevelData.level_data = LevelInfo.new(active_level_code).level_data
	get_tree().reload_current_scene()
	

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.begins_with("manual_" + LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data()).level_name):
			files.append(file)

	dir.list_dir_end()

	return files

func on_clear_pressed():
	var dir = Directory.new()
	dir.open("user://autosave")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.begins_with("manual_" + LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data()).level_name):
			dir.remove("user://autosave/" + file)
			print("user://autosave/" + file)
	dir.remove("user://autosave/" + LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data()).level_name + "_main.autosave")
	dir.list_dir_end()
	hide()
	$"../LevelName".show()
