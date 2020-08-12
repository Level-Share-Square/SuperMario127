extends Screen

const PLAYER_SCENE : PackedScene = preload("res://scenes/player/player.tscn")
const EDITOR_SCENE : PackedScene = preload("res://scenes/editor/editor.tscn")

const TEMPLATE_LEVEL  : String = preload("res://assets/level_data/template_level.tres").contents

const NO_LEVEL : int = -1

# not really a fan of these giant node paths but it'll have to do for now, not sure what a better system would be just yet
onready var level_list : ItemList = $MarginContainer/HBoxContainer/VBoxContainer/LevelListPanel/LevelList

# buttons
onready var button_back : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonBack
onready var button_add: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonAdd
onready var button_copy_code : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonCopyCode

onready var button_new_level : Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/HBoxContainer/ButtonNewLevel
onready var button_code_import : Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/HBoxContainer/ButtonCodeImport
onready var button_code_cancel : Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/ButtonCodeCancel

onready var button_play : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonPlay
onready var button_edit : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonEdit
onready var button_delete : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonDelete
onready var button_reset : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonReset

onready var button_time_scores : Button = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/CoinsAndTime/ButtonTimeScores

# toggleable panels 
onready var level_list_panel : PanelContainer = $MarginContainer/HBoxContainer/VBoxContainer/LevelListPanel
onready var level_code_panel : PanelContainer = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel

# level info
onready var level_name_label : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelName
onready var shine_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/ShinesAndStarCoins/PanelContainer/HBoxContainer2/ShineProgressLabel
onready var star_coin_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/ShinesAndStarCoins/PanelContainer2/HBoxContainer3/StarCoinProgressLabel

onready var level_code_entry : TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/LevelCodeEntry

func _ready() -> void:
	var _connect

	_connect = level_list.connect("item_selected", self, "on_level_selected")

	_connect = button_back.connect("pressed", self, "on_button_back_pressed")
	_connect = button_add.connect("pressed", self, "on_button_add_pressed")
	_connect = button_copy_code.connect("pressed", self, "on_button_copy_code_pressed")

	_connect = button_new_level.connect("pressed", self, "on_button_new_level_pressed")
	_connect = button_code_import.connect("pressed", self, "on_button_code_import_pressed")
	_connect = button_code_cancel.connect("pressed", self, "on_button_code_cancel_pressed")

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

func add_level(level_info : LevelInfo):
	# generate a (hopefully) unique name for each level
	var level_disk_path = SavedLevels.generate_level_disk_path(level_info)

	var error_code = SavedLevels.save_level_to_disk(level_info, level_disk_path)
	if error_code == OK:
		SavedLevels.levels.append(level_info)
		level_list.add_item(level_info.level_name)

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

func set_level_code_panel(new_value : bool):
	level_list_panel.visible = !new_value 
	level_code_panel.visible = new_value

# signal responses

func on_level_selected(index : int) -> void:
	SavedLevels.selected_level = index
	var level_info : LevelInfo = SavedLevels.levels[SavedLevels.selected_level]
	populate_info_panel(level_info)

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "levels_screen", "main_menu_screen")

func on_button_add_pressed() -> void:
	set_level_code_panel(true)

# note: random music selection doesn't currently work with this new method of making new levels, functionality needs to be added here for that
func on_button_new_level_pressed() -> void:
	# this way of doing it is a bit silly but should work fine unless the import button code massively changes
	level_code_entry.text = TEMPLATE_LEVEL
	on_button_code_import_pressed()

func on_button_code_import_pressed() -> void:
	var level_code = level_code_entry.text
	# if the entry box is empty, then try using the clipboard value instead, neat little shortcut
	if level_code == "":
		level_code = OS.clipboard

	if level_code_util.is_valid(level_code):
		var level_info : LevelInfo = LevelInfo.new(level_code)
		add_level(level_info)
		level_code_entry.text = ""
		set_level_code_panel(false)

func on_button_code_cancel_pressed() -> void:
	level_code_entry.text = ""
	set_level_code_panel(false)

func on_button_copy_code_pressed() -> void:
	var selected_level = SavedLevels.selected_level
	if selected_level == -1:
		return 
	OS.clipboard = SavedLevels.levels[selected_level].level_code
		
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
