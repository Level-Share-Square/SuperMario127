extends Screen

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const EDITOR_SCENE = preload("res://scenes/editor/editor.tscn")

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

	for level_info in SavedLevels.levels:
		level_list.add_item(level_info.level_name)

func populate_info_panel(level_info : LevelInfo = null) -> void:
	if level_info != null:
		level_name_label.text = level_info.level_name
		shine_progress.text = "%s/%s" % [level_info.collected_shines, level_info.shine_count]
	else: # no level provided, set everything to empty level values
		level_name_label.text = ""

func add_level_with_save(level_info : LevelInfo):
	level_list.add_item(level_info.level_name)

	# generate a (hopefully) unique name for each level
	var level_disk_path = SavedLevels.generate_level_disk_path(level_info)

	var error_code = SavedLevels.save_level_to_disk(level_info, level_disk_path)
	if error_code == OK:
		SavedLevels.levels_disk_paths.append(level_disk_path)
		SavedLevels.save_level_paths_to_disk()

func delete_level(index : int) -> void:
	var level_disk_path = SavedLevels.levels_disk_paths[index]

	SavedLevels.levels.remove(index)
	SavedLevels.levels_disk_paths.remove(index)
	level_list.remove_item(index)

	SavedLevels.save_level_paths_to_disk()
	SavedLevels.delete_level_from_disk(level_disk_path)

	# this block updates the selected level as levels are deleted:
	# set selected level to -1 if there's no levels 
	var level_count = SavedLevels.levels.size()
	var selected_level = SavedLevels.selected_level * int(level_count > 0) + -1 * int(not level_count > 0)
	# decrement the selected level by 1 if we just deleted the last level
	selected_level -= 1 * int(selected_level + 1 > level_count)
	level_list.select(selected_level) # make sure the ItemList also reflects the new selection

	SavedLevels.selected_level = selected_level

	# pass null to populate_info_panel if there's no levels left, so it can make the info panel empty
	populate_info_panel(SavedLevels.levels[selected_level] if selected_level != -1 else null)

# signal responses

func on_level_selected(index : int) -> void:
	SavedLevels.selected_level = index
	var level_info : LevelInfo = SavedLevels.levels[SavedLevels.selected_level]
	populate_info_panel(level_info)

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "levels_screen", "main_menu_screen")

func on_button_add_pressed() -> void:
	if level_code_util.is_valid(OS.clipboard):
		var level_info : LevelInfo = LevelInfo.new(OS.clipboard)
		add_level_with_save(level_info)
		
func on_button_play_pressed() -> void:
	var selected_level = SavedLevels.selected_level
	if selected_level == -1:
		return #at some point the buttons should be disabled when you don't have a level selected, keep this failsafe anyway though
	var level_info = SavedLevels.levels[selected_level]
	CurrentLevelData.level_data = level_info.level_data

	var _change_scene = get_tree().change_scene_to(PLAYER_SCENE)

func on_button_edit_pressed() -> void:
	var selected_level = SavedLevels.selected_level
	if selected_level == -1:
		return
	var level_info : LevelInfo = SavedLevels.levels[selected_level]
	CurrentLevelData.level_data = level_info.level_data

	var _change_scene = get_tree().change_scene_to(EDITOR_SCENE)

func on_button_delete_pressed() -> void:
	var selected_level = SavedLevels.selected_level
	if selected_level == -1:
		return
	delete_level(selected_level) 

func on_button_reset_pressed() -> void:
	var selected_level = SavedLevels.selected_level
	if selected_level == -1:
		return
	var level_info : LevelInfo = SavedLevels.levels[selected_level] 
	LevelInfo.reset_save_data(level_info)
