extends Screen

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const EDITOR_SCENE = preload("res://scenes/editor/editor.tscn")

# not really a fan of these giant node paths but it'll have to do for now, not sure what a better system would be just yet
onready var level_list : ItemList = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/LevelList

# buttons
onready var button_back : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonBack
onready var button_add: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonAdd

onready var button_play : Button = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/ControlButtons/ButtonPlay
onready var button_edit : Button = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/ControlButtons/ButtonEdit
onready var button_delete : Button = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/ControlButtons/ButtonDelete
onready var button_reset : Button = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/ControlButtons/ButtonReset

onready var button_time_scores : Button = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/LevelScore/CoinsAndTime/ButtonTimeScores

# level info
onready var level_name_label : Label = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/LevelName
onready var shine_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/LevelScore/ShinesAndStarCoins/PanelContainer/HBoxContainer2/Label
onready var star_coin_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/VBoxContainer/LevelScore/ShinesAndStarCoins/PanelContainer2/HBoxContainer3/Label

var levels : Array = []
var selected_level : int = -1 # -1 means no level is selected

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

func populate_info_panel(level_info : LevelInfo = null) -> void:
	if level_info != null:
		level_name_label.text = level_info.level_name
		shine_progress.text = "%s/%s" % [level_info.collected_shines, level_info.shine_count]
	else: # no level provided, set everything to empty level values
		level_name_label.text = ""

func add_level(level_info : LevelInfo) -> void:
	levels.append(level_info)
	level_list.add_item(level_info.level_name)

func delete_level(index : int) -> void:
	levels.remove(index)
	level_list.remove_item(index)

# signal responses

func on_level_selected(index : int) -> void:
	selected_level = index
	var level_info = levels[selected_level]
	populate_info_panel(level_info)

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "levels_screen", "main_menu_screen")

func on_button_add_pressed() -> void:
	if level_code_util.is_valid(OS.clipboard):
		var level_data = LevelData.new()
		level_data.load_in(OS.clipboard)

		var level_info = LevelInfo.new(level_data)
		add_level(level_info)
		
func on_button_play_pressed() -> void:
	if selected_level == -1:
		return #at some point the buttons should be disabled when you don't have a level selected, keep this failsafe anyway though
	var level_info = levels[selected_level]
	CurrentLevelData.level_data = level_info.level_data

	var _change_scene = get_tree().change_scene_to(PLAYER_SCENE)

func on_button_edit_pressed() -> void:
	if selected_level == -1:
		return
	var level_info = levels[selected_level]
	CurrentLevelData.level_data = level_info.level_data

	var _change_scene = get_tree().change_scene_to(EDITOR_SCENE)

func on_button_delete_pressed() -> void:
	if selected_level == -1:
		return
	delete_level(selected_level) 

func on_button_reset_pressed() -> void:
	if selected_level == -1:
		return
	var level_info = levels[selected_level] 
	LevelInfo.reset_save_data(level_info)
