extends Screen

# for the level delete confirmation window
signal open_delete_confirmation_popup

# not really a fan of these giant node paths but it'll have to do for now, not sure what a better system would be just yet
onready var level_list : ItemList = $MarginContainer/HBoxContainer/VBoxContainer/LevelListPanel/LevelList

# buttons
onready var button_back : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonBack
onready var button_add : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonAdd
onready var button_copy_code : Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ButtonCopyCode

onready var button_new_level : Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/HBoxContainer/ButtonNewLevel
onready var button_code_import : Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/HBoxContainer/ButtonCodeImport
onready var button_code_cancel : Button = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/ButtonCodeCancel

onready var button_play : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonPlay
onready var button_edit : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonEdit
onready var button_delete : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonDelete
onready var button_reset : Button = $MarginContainer/HBoxContainer/LevelInfo/ControlButtons/ButtonReset

onready var button_time_scores : Button = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/ButtonTimeScores
onready var button_close_time_scores : Button = $MarginContainer/HBoxContainer/TimeScorePanel/PanelContainer/VBoxContainer/ButtonCloseTimeScore

# toggleable panels 
onready var template_level_info : PanelContainer = $MarginContainer/HBoxContainer/VBoxContainer/TemplateLevelInfo
onready var level_list_panel : PanelContainer = $MarginContainer/HBoxContainer/VBoxContainer/LevelListPanel
onready var level_code_panel : PanelContainer = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel
onready var single_time_score_panel : PanelContainer = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/SingleTimeScorePanel 
onready var level_info_panel : VBoxContainer = $MarginContainer/HBoxContainer/LevelInfo
onready var time_score_panel : PanelContainer = $MarginContainer/HBoxContainer/TimeScorePanel

# level info
onready var level_sky_thumbnail : TextureRect = $MarginContainer/HBoxContainer/LevelInfo/LevelThumbnail/PanelContainer/ThumbnailImage
onready var level_foreground_thumbnail : TextureRect = $MarginContainer/HBoxContainer/LevelInfo/LevelThumbnail/PanelContainer/ForegroundThumbnailImage
onready var level_name_label : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelName
onready var shine_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/ShineProgressPanel/HBoxContainer2/ShineProgressLabel
onready var star_coin_progress : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/StarCoinProgressPanel/HBoxContainer3/StarCoinProgressLabel
onready var coin_score : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/CoinScorePanel/HBoxContainer2/Label
onready var single_time_score : Label = $MarginContainer/HBoxContainer/LevelInfo/LevelScore/SingleTimeScorePanel/HBoxContainer3/Label
onready var time_score_list : ItemList = $MarginContainer/HBoxContainer/TimeScorePanel/PanelContainer/VBoxContainer/TimeScoreList

onready var level_code_entry : TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/LevelCodePanel/PanelContainer/VBoxContainer/LevelCodeEntry

onready var pop_up_container = $PopupContainer
onready var confirm_delete_window = $PopupContainer/ConfirmDelete

const PLAYER_SCENE : PackedScene = preload("res://scenes/player/player.tscn")
const EDITOR_SCENE : PackedScene = preload("res://scenes/editor/editor.tscn")

const TEMPLATE_LEVEL: String = preload("res://assets/level_data/template_level.tres").contents

const NO_LEVEL : int = -1

const DEFAULT_SKY_THUMBNAIL : StreamTexture = preload("res://scenes/shared/background/backgrounds/day/day.png")
const DEFAULT_FOREGROUND_MODULATE : Color = Color(1, 1, 1)
const DEFAULT_FOREGROUND_THUMBNAIL : StreamTexture = preload("res://scenes/shared/background/foregrounds/hills/preview.png")

var levels = Singleton.SavedLevels.levels

var double_click := false

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

	_connect = button_time_scores.connect("pressed", self, "on_button_time_scores_pressed")
	_connect = button_close_time_scores.connect("pressed", self, "on_button_close_time_scores_pressed")
	
	_connect = confirm_delete_window.connect("confirmed", self, "delete_level")
	_connect = connect("open_delete_confirmation_popup", confirm_delete_window, "popup_centered")

	_pre_open_screen() # In case we're exiting a level

func _pre_open_screen() -> void:
	levels = Singleton.SavedLevels.template_levels if Singleton.SavedLevels.is_template_list else Singleton.SavedLevels.levels
	print("Levels: ", levels.size())
	
	for button in [button_add]:
		button.disabled = Singleton.SavedLevels.is_template_list
	template_level_info.visible = Singleton.SavedLevels.is_template_list
	button_copy_code.text = "Copy to Levels" if Singleton.SavedLevels.is_template_list else "Copy Level Code"
	
	# TODO: replace this for the template list
	level_list.clear()
	for level_info in levels:
		level_list.add_item(level_info.level_name)
	
	# Empty levels list, so just empty out the info panel
	if levels.size() == 0:
		Singleton.SavedLevels.selected_level = NO_LEVEL
		populate_info_panel()
	elif Singleton.SavedLevels.selected_level != NO_LEVEL:
		# otherwise if it's not NO_LEVEL, we're probably returning to the menu after leaving a stage
		if Singleton.SavedLevels.selected_level < levels.size():
			populate_info_panel(levels[Singleton.SavedLevels.selected_level])
		level_list.select(Singleton.SavedLevels.selected_level)
	else: # no level selected, but we have levels, so select the first one
		populate_info_panel(levels[0])
		Singleton.SavedLevels.selected_level = 0
		level_list.select(0)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			double_click = event.doubleclick
	
	if !can_interact or get_focus_owner() != null:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		button_play.grab_focus()
	elif Input.is_action_just_pressed("ui_down"):
		level_list.grab_focus()
	elif Input.is_action_just_pressed("ui_left"):
		button_reset.grab_focus()
	elif Input.is_action_just_pressed("ui_right"):
		button_back.grab_focus()
	elif Input.is_action_just_pressed("switch_modes"):
		start_level(false)

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

		shine_progress.text = "%s/%s" % [collected_shine_count, total_shine_count]

		var collected_star_coin_count = level_info.collected_star_coins.values().count(true)
		star_coin_progress.text = "%s/%s" % [collected_star_coin_count, level_info.collected_star_coins.size()]
		
		# set the little thumbnail to look just like the actual level background
		level_sky_thumbnail.texture = level_info.get_level_background_texture()
		level_foreground_thumbnail.modulate = level_info.get_level_background_modulate()
		level_foreground_thumbnail.texture = level_info.get_level_foreground_texture()

		coin_score.text = str(level_info.coin_score)

		# TODO: replace multi-shine time scores with some custom thing, ItemList is not a good fit
		# displaying time scores
		if level_info.shine_details.size() > 1:
			set_time_score_button(true)

			time_score_list.clear()
			
			var time_scores = level_info.time_scores.values()

			var shine_details_sorted = ([] + level_info.shine_details)
			shine_details_sorted.sort_custom(LevelInfo, "shine_sort")
			
			for shine_detail in shine_details_sorted:
				var index = 0
				for shine_detail_2 in level_info.shine_details: # had to do this instead because bug
					if shine_detail["id"] == shine_detail_2["id"]:
						break
					index += 1
				#var index = level_info.shine_details.bsearch(shine_detail) - doesn't work ae
				var time_score = time_scores[shine_detail.id if shine_detail.id < time_scores.size() else (time_scores.size() - 1)]
				if time_score != -1:
					var time_score_string : String = LevelInfo.generate_time_string(time_score)
					time_score_list.add_item(shine_detail.title + ":")
					time_score_list.add_item(time_score_string)
				else: 
					time_score_list.add_item(shine_detail.title + ":")
					time_score_list.add_item(":\n--:--.--")
		else: 
			set_time_score_button(false)
			# if there is at least one time, and that time isn't an empty time
			if level_info.time_scores.size() > 0 and level_info.time_scores.values()[0] != LevelInfo.EMPTY_TIME_SCORE:
				single_time_score.text = LevelInfo.generate_time_string(level_info.time_scores.values()[0])
			else:
				single_time_score.text = "--:--.--"
		
		set_control_buttons(true)
		
	else: # no level provided, set everything to empty level values
		level_name_label.text = ""
		shine_progress.text = "0/0"
		star_coin_progress.text = "0/0"

		level_sky_thumbnail.texture = DEFAULT_SKY_THUMBNAIL
		level_foreground_thumbnail.modulate = DEFAULT_FOREGROUND_MODULATE
		level_foreground_thumbnail.texture = DEFAULT_FOREGROUND_THUMBNAIL

		coin_score.text = str(0)

		single_time_score.text = "--:--.--"
		set_time_score_button(false)

		set_control_buttons(false)

func add_level(level_info : LevelInfo):
	if Singleton.SavedLevels.is_template_list: return # The button shouldn't be clickable, but just in case
	# generate a (hopefully) unique name for each level
	var level_disk_path = Singleton.SavedLevels.generate_level_disk_path(level_info)

	var error_code = Singleton.SavedLevels.save_level_to_disk(level_info, level_disk_path)
	if error_code == OK:
		levels.append(level_info)
		level_list.add_item(level_info.level_name)

		Singleton.SavedLevels.levels_disk_paths.append(level_disk_path)
		Singleton.SavedLevels.save_level_paths_to_disk()

func delete_level(index : int) -> void:
	if Singleton.SavedLevels.is_template_list: return # The button shouldn't be clickable, but just in case
	var level_disk_path = Singleton.SavedLevels.levels_disk_paths[index]

	levels.remove(index)
	Singleton.SavedLevels.levels_disk_paths.remove(index)
	level_list.remove_item(index)

	Singleton.SavedLevels.save_level_paths_to_disk()
	Singleton.SavedLevels.delete_level_from_disk(level_disk_path)

	# this block updates the selected level as levels are deleted:
	# set selected level to NO_LEVEL if there's no levels 
	var level_count = levels.size()
	var selected_level = Singleton.SavedLevels.selected_level * int(level_count > 0) + NO_LEVEL * int(not level_count > 0)
	# decrement the selected level by 1 if we just deleted the last level
	selected_level -= 1 * int(selected_level + 1 > level_count)
	level_list.select(selected_level) # make sure the ItemList also reflects the new selection

	Singleton.SavedLevels.selected_level = selected_level

	# pass null to populate_info_panel if there's no levels left, so it can make the info panel empty
	populate_info_panel(levels[selected_level] if selected_level != NO_LEVEL else null)

func start_level(start_in_edit_mode : bool):
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return #at some point the buttons should be disabled when you don't have a level selected, keep this failsafe anyway though
	if start_in_edit_mode and Singleton.SavedLevels.is_template_list: # Can't edit template levels
		return
	
	# so you aren't able to press the button while it's transitioning
	can_interact = false
	
	var level_info = levels[selected_level]
	Singleton.CurrentLevelData.level_data = level_info.level_data

	# if it's a multi-shine level, open the shine select screen, otherwise open the level directly 
	# TODO: additional checks for things like all shines set to not show in menu and such
	# using collected_shines for the size check because there can only be one entry in collected shines per id, while shine_details can have multiple shines with the same id
	if !start_in_edit_mode:
		# Get the shine count, only count shine sprites that have show_in_menu on
		var total_shine_count := 0
		for shine_details in level_info.shine_details:
			if shine_details["show_in_menu"]:
				total_shine_count += 1
		# If there is more than 1, go to shine select screen
		if total_shine_count > 1:
			Singleton.Music.change_song(Singleton.Music.last_song, 0) # temp
			emit_signal("screen_change", "levels_screen", "shine_select_screen") 
			return

	# if it's not a multishine level, play a transition and change to play/edit scene

	# not a multishine level, but if there's 1 shine we should set it as selected 
	if level_info.shine_details.size() == 1:
		level_info.selected_shine = 0

	# use the first fire of the transition_finished signal to change the scene when the screen finishes transitioning out
	var goal_scene = EDITOR_SCENE if start_in_edit_mode else PLAYER_SCENE
	var _connect = Singleton.SceneTransitions.connect("transition_finished", get_tree(), "change_scene_to", [goal_scene], CONNECT_ONESHOT)
	
	Singleton.SceneTransitions.play_transition_audio()
	Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Color(1, 1, 1, 0), Color(1, 1, 1, 1))

func set_level_code_panel(new_value : bool):
	level_list_panel.visible = !new_value 
	level_code_panel.visible = new_value

func set_time_score_button(new_value : bool):
	single_time_score_panel.visible = !new_value 
	button_time_scores.visible = new_value

func set_time_score_panel(new_value : bool):
	level_info_panel.visible = !new_value 
	time_score_panel.visible = new_value

func set_control_buttons(is_enabled : bool) -> void:
	button_play.disabled = !is_enabled
	button_edit.disabled = !is_enabled || Singleton.SavedLevels.is_template_list
	button_delete.disabled = !is_enabled || Singleton.SavedLevels.is_template_list
	button_reset.disabled = !is_enabled

# signal responses

func on_level_selected(index : int) -> void:
	Singleton.SavedLevels.selected_level = index
	var level_info : LevelInfo = levels[Singleton.SavedLevels.selected_level]
	populate_info_panel(level_info)
	
	print(double_click)
	if double_click:
		start_level(false)

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "levels_screen", "main_menu_screen")

func on_button_add_pressed() -> void:
	set_level_code_panel(true)

	button_code_cancel.grab_focus()

# note: random music selection doesn't currently work with this new method of making new levels, functionality needs to be added here for that
func on_button_new_level_pressed() -> void:
	# this way of doing it is a bit silly but should work fine unless the import button code massively changes
	# should move the common code to a function instead of calling the import signal response
	level_code_entry.text = TEMPLATE_LEVEL
	on_button_code_import_pressed()

# the new level button uses this function after setting the level_code_entry text to the template level
# keep that in mind when editing this
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
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return
	
	if Singleton.SavedLevels.is_template_list: # Copy to Levels
		# Hacky solution to import the level
		Singleton.SavedLevels.is_template_list = false
		# level_code_entry.text is what is used by on_button_code_import_pressed()
		var tmp := level_code_entry.text
		level_code_entry.text = levels[selected_level].level_code
		_pre_open_screen() # Switch to the levels screen first,
		on_button_code_import_pressed() # then import the level
		level_code_entry.text = tmp # I swear I did not touch it!
		
	else: # Copy Level Code
		OS.clipboard = levels[selected_level].level_code

func on_button_play_pressed() -> void:
	if !can_interact:
		return
	start_level(false)

func on_button_edit_pressed() -> void:
	if !can_interact:
		return
	start_level(true)

func on_button_delete_pressed() -> void:
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return
	
	var level_code = levels[selected_level].level_code
	var level_info : LevelInfo = LevelInfo.new(level_code)
	
	pop_up_container.visible = true
	confirm_delete_window.set_level_name(level_info.level_name)
	confirm_delete_window.index_to_send = selected_level
	emit_signal("open_delete_confirmation_popup")

func on_button_reset_pressed() -> void:
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return
	var level_info = levels[selected_level]
	level_info.reset_save_data()
	populate_info_panel(level_info)

# plan for populating the speedrun times panel is to give each time an icon to say if the shine is collected or not, and then use the text spot for the exact time (maybe add a suffix with the shine number?)
func on_button_time_scores_pressed() -> void:
	set_time_score_panel(true)

	button_close_time_scores.grab_focus()

func on_button_close_time_scores_pressed() -> void:
	set_time_score_panel(false)
