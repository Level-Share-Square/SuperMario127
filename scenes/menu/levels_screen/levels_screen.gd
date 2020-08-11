extends Screen

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const EDITOR_SCENE = preload("res://scenes/editor/editor.tscn")

const LEVELS_DIRECTORY = "user://levels/"
const LEVEL_DISK_PATHS_PATH = LEVELS_DIRECTORY + "paths.json"

const ENCRYPTION_PASSWORD = "BadCode"

# not really a fan of these giant node paths but it'll have to do for now, not sure what a better system would be just yet
onready var level_list : ItemList = $MarginContainer/HBoxContainer/VBoxContainer/LevelListPanel/LevelList

# buttons
onready var button_back : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonBack
onready var button_add: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonAdd

onready var button_play : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonPlay
onready var button_edit : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonEdit
onready var button_delete : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonDelete
onready var button_reset : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonReset

onready var button_time_scores : Button = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/CoinsAndTime/ButtonTimeScores

# level info
onready var level_name_label : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelName
onready var shine_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/ShinesAndStarCoins/PanelContainer/HBoxContainer2/ShineProgressLabel
onready var star_coin_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/ShinesAndStarCoins/PanelContainer2/HBoxContainer3/StarCoinProgressLabel

# these arrays should probably be moved to a singleton
var levels : Array = [] # array of type LevelInfo
var levels_disk_paths : Array = [] # array of type String
var selected_level : int = -1 # -1 means no level is selected

# we can just reuse these objects for everything involving files, nothing will happen in parallel atm anyway
var file : File = File.new()
var directory : Directory = Directory.new()

func _ready() -> void:
	var _connect

	_connect = level_list.connect("item_selected", self, "on_level_selected")

	_connect = button_back.connect("pressed", self, "on_button_back_pressed")
	_connect = button_add.connect("pressed", self, "on_button_add_pressed")

	_connect = button_play.connect("pressed", self, "on_button_play_pressed")
	_connect = button_edit.connect("pressed", self, "on_button_edit_pressed")
	_connect = button_delete.connect("pressed", self, "on_button_delete_pressed")
	_connect = button_reset.connect("pressed", self, "on_button_reset_pressed")

	populate_info_panel() #make sure everything is reset to empty level values

	load_level_paths_from_disk()
	for level_path in levels_disk_paths:
		load_level_from_disk(level_path)

func populate_info_panel(level_info : LevelInfo = null) -> void:
	if level_info != null:
		level_name_label.text = level_info.level_name
		shine_progress.text = "%s/%s" % [level_info.collected_shines, level_info.shine_count]
	else: # no level provided, set everything to empty level values
		level_name_label.text = ""

func add_level(level_info : LevelInfo) -> void:
	levels.append(level_info)
	level_list.add_item(level_info.level_name)

# these are separate so when the game starts it can populate the list with add_level(), 
# but when a user adds a level it should use add_level_with_save()
func add_level_with_save(level_info : LevelInfo):
	add_level(level_info)

	# generate a (hopefully) unique name for each level
	var level_disk_path = LEVELS_DIRECTORY + "%s_%s.level" % [hash(level_info), hash(OS.get_datetime())]

	# the odds of this happening (since the datetime is used in the calculation)
	# should be next to impossible, but error checking doesn't hurt I guess 
	if file.file_exists(level_disk_path): 
		return # this should be changed to display an error message later


	levels_disk_paths.append(level_disk_path)
	save_level_paths_to_disk()
	save_level_to_disk(level_info, level_disk_path)

func delete_level(index : int) -> void:
	var level_disk_path = levels_disk_paths[index]

	levels.remove(index)
	level_list.remove_item(index)
	levels_disk_paths.remove(index)

	save_level_paths_to_disk()
	delete_level_from_disk(level_disk_path)

	# this block updates the selected level as levels are deleted:
	# set selected level to -1 if there's no levels 
	selected_level = selected_level * int(levels.size() > 0) + -1 * int(not levels.size() > 0)
	# decrement the selected level by 1 if we just deleted the last level
	selected_level -= 1 * int(selected_level + 1 > levels.size())
	level_list.select(selected_level) # make sure the ItemList also reflects the new selection

	# pass null to populate_info_panel if there's no levels left, so it can make the info panel empty
	populate_info_panel(levels[selected_level] if selected_level != -1 else null)

func save_level_paths_to_disk() -> void:
	var levels_disk_paths_json = to_json(levels_disk_paths)

	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open(LEVEL_DISK_PATHS_PATH, File.WRITE)
	if error_code == OK:
		file.store_string(levels_disk_paths_json)
		file.close()

func save_level_to_disk(level_info : LevelInfo, level_path : String) -> void:
	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open_encrypted_with_pass(level_path, File.WRITE, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary = level_info.get_saveable_dictionary()
		var level_save_dictionary_json = to_json(level_save_dictionary)
		file.store_string(level_save_dictionary_json)
		file.close()

func delete_level_from_disk(level_path : String) -> void:
	var _error_code = directory.remove(level_path)

func load_level_paths_from_disk() -> void:
	var error_code = file.open(LEVEL_DISK_PATHS_PATH, File.READ)
	if error_code == OK:
		var levels_disk_paths_json = file.get_line()
		levels_disk_paths = parse_json(levels_disk_paths_json)
		file.close()

func load_level_from_disk(level_path : String) -> void:
	var error_code = file.open_encrypted_with_pass(level_path, File.READ, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary_json = file.get_line()
		var level_save_dictionary = parse_json(level_save_dictionary_json)

		var level_info = LevelInfo.new()
		level_info.load_from_dictionary(level_save_dictionary)

		add_level(level_info)
		file.close()

# signal responses

func on_level_selected(index : int) -> void:
	selected_level = index
	var level_info : LevelInfo = levels[selected_level]
	populate_info_panel(level_info)

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "levels_screen", "main_menu_screen")

func on_button_add_pressed() -> void:
	if level_code_util.is_valid(OS.clipboard):
		var level_info : LevelInfo = LevelInfo.new(OS.clipboard)
		add_level_with_save(level_info)
		
func on_button_play_pressed() -> void:
	if selected_level == -1:
		return #at some point the buttons should be disabled when you don't have a level selected, keep this failsafe anyway though
	var level_info = levels[selected_level]
	CurrentLevelData.level_data = level_info.level_data

	var _change_scene = get_tree().change_scene_to(PLAYER_SCENE)

func on_button_edit_pressed() -> void:
	if selected_level == -1:
		return
	var level_info : LevelInfo = levels[selected_level]
	CurrentLevelData.level_data = level_info.level_data

	var _change_scene = get_tree().change_scene_to(EDITOR_SCENE)

func on_button_delete_pressed() -> void:
	if selected_level == -1:
		return
	delete_level(selected_level) 

func on_button_reset_pressed() -> void:
	if selected_level == -1:
		return
	var level_info : LevelInfo = levels[selected_level] 
	LevelInfo.reset_save_data(level_info)
