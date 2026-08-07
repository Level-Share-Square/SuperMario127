extends Control


const TIME_SCORE_SCENE: PackedScene = preload("res://scenes/menu/levels_list/level_panel/time_score.tscn")

onready var list_handler = $"%ListHandler"
onready var http_thumbnails = $"%HTTPThumbnails"
onready var default_thumbnail = preload("res://scenes/menu/level_portal/default_thumb.png")

var working_folder: String
var level_id: String
var level_metadata: LevelMetadata
var can_edit: bool
var is_campaign: bool
var previous_number_of_players: int = 0
var starting_level: bool = false

### tabs
onready var info_tab: Control = $InfoTab
onready var scores_tab: Control = $ScoresTab

onready var view_button: Button = $Buttons/ViewTab
onready var view_time_icon: TextureRect = $Buttons/ViewTab/TimeIcon
onready var view_info_icon: TextureRect = $Buttons/ViewTab/InfoIcon

export var view_scores_text: String
export var view_info_text: String

### info
onready var title := $InfoTab/Info/Title
onready var title_shadow := $InfoTab/Info/Title/Shadow

export var author_prefix: String = "by "
onready var author := $InfoTab/Info/Author

onready var description := $InfoTab/Panel/MarginContainer/Description

onready var thumbnail := $InfoTab/Thumbnail
onready var foreground := $InfoTab/Thumbnail/Foreground

onready var shine_label := $InfoTab/Info/Shines/Label
onready var star_coin_label := $InfoTab/Info/StarCoins/Label

export var completion_color: Color = Color("ffffc4")
onready var percentage_label := $InfoTab/Info/Completion/Percentage

onready var shines = $InfoTab/Info/Shines
onready var star_coins = $InfoTab/Info/StarCoins
onready var completion = $InfoTab/Info/Completion

### time scores
onready var time_scores_container: VBoxContainer = $ScoresTab/Panel/ScrollContainer/MarginContainer/VBoxContainer

### buttons
onready var play_button = $Buttons/PlayLevel
onready var back_button = $Buttons/Return
onready var edit_button = $Buttons/EditLevel
onready var view_tab = $Buttons/ViewTab
onready var reset_button = $Buttons/ResetSave
onready var delete_button = $Buttons/DeleteLevel

func load_collectibles_info(save_data: LevelSaveData)-> void:
	
	var total_shine_count: int = save_data.get_total_mission_count()
	var collected_shine_count: int = save_data.get_completed_mission_count()
	
	if is_campaign:
		shine_label.text = str(total_shine_count)
		shine_label.modulate = Color.white
	else:
		shine_label.text = str(collected_shine_count) + "/" + str(total_shine_count)
		shine_label.modulate = completion_color if (collected_shine_count >= total_shine_count) else Color.white
	
	var total_star_coin_count: int = save_data.get_total_star_coin_count()
	var collected_star_coin_count: int = save_data.get_collected_star_coin_count()
	
	if is_campaign:
		star_coin_label.text = str(total_star_coin_count)
		star_coin_label.modulate = Color.white
	else:
		star_coin_label.text = str(collected_star_coin_count) + "/" + str(total_star_coin_count)
		star_coin_label.modulate = completion_color if (collected_star_coin_count >= total_star_coin_count) else Color.white

func load_level_info(_level_metadata: LevelMetadata, _level_id: String, _working_folder: String, _can_edit: bool = true, _is_campaign: bool = false):
	yield(get_parent(), "screen_opened")
	
	CurrentLevelData.level_metadata = _level_metadata
	CurrentLevelData.level_id = _level_id
	CurrentLevelData.load_save_data()
	
	level_metadata = CurrentLevelData.level_metadata
	level_id = _level_id
	working_folder = _working_folder
	can_edit = _can_edit
	is_campaign = _is_campaign
	
	var current_number_of_players: int = Singleton.PlayerSettings.number_of_players
	
	previous_number_of_players = int(current_number_of_players)
	
	if not level_code_validator_util.validate_level_code(level_list_util.get_level_code_from_id(level_id, working_folder)):
		# Invalid level detected!
		edit_button.visible = false
		play_button.visible = false
		title.text = "Invalid Level"
		author.text = ""
		title_shadow.text = title.text
		description.bbcode_text = "[center]" + "I'm gay." + "[/center]"
		back_button.focus_neighbour_top = back_button.get_path_to(reset_button)
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(back_button)

		foreground.visible = false
		thumbnail.texture = default_thumbnail

		load_time_scores()
		load_collectibles_info(LevelSaveData.new("", ""))
		percentage_label.text = "100%"
		percentage_label.modulate = completion_color

		return
	
	play_button.visible = true
	view_tab.visible = not is_campaign
	reset_button.visible = not is_campaign
	
	completion.visible = not is_campaign
	
	title.text = level_metadata.level_name
	title_shadow.text = title.text
	
	author.text = author_prefix + level_metadata.level_author
	description.bbcode_text = "[center]" + level_metadata.level_description + "[/center]"
	
	# buttons
	edit_button.visible = can_edit
	delete_button.visible = can_edit
	if not can_edit:
		back_button.focus_neighbour_top = back_button.get_path_to(reset_button)
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(back_button)
	else:
		back_button.focus_neighbour_top = back_button.get_path_to(delete_button)
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(delete_button)
	
	# thumbnail
	var cached_image: ImageTexture = yield(AssetHandler.load_image(level_metadata.level_thumbnail_url, working_folder, level_id), "completed")
	
	var old_level_thumbnail: String = level_list_util.get_level_thumbnail_path(level_id, working_folder)
	if level_list_util.file_exists(old_level_thumbnail):
		cached_image = level_list_util.get_image_from_path(old_level_thumbnail)
		
	if cached_image == null:
		thumbnail.texture = level_metadata.get_level_background_texture()
		
		foreground.visible = true
		foreground.modulate = level_metadata.get_level_background_modulate()
		foreground.texture = level_metadata.get_level_foreground_texture()
	else:
		thumbnail.texture = cached_image
		foreground.visible = false
	
	# load save file
	load_time_scores()



	var save_data: LevelSaveData = CurrentLevelData.save_data
	load_collectibles_info(save_data)

	# these are floats cuz they need to be divided for some calculations :)
	var total_collectibles: float = save_data.get_total_mission_count() + save_data.get_total_star_coin_count()
	var total_collected: float = save_data.get_completed_mission_count() + save_data.get_collected_star_coin_count()
	if total_collectibles <= 0:
		percentage_label.text = "100%"
		percentage_label.modulate = completion_color
		return # OTHERWISE THE UNIVERSE WILL EXPLODEEEE ZOMG

	var completion_percent: float = stepify(total_collected / total_collectibles, 0.01) * 100
	percentage_label.modulate = completion_color if (completion_percent >= 100) else Color.white
	percentage_label.text = str(completion_percent) + "%"


func load_time_scores():
	for child in time_scores_container.get_children():
		# go, my children, be free
		child.queue_free()
	
#	var save_data: LevelSaveData = CurrentLevelData.save_data
#	var mission_ids = save_data.get_completed_missions()
#
#	for mission_id in mission_ids:
#		var time_score = save_data.get_time_score(mission_id)
#		if time_score != null:
#			var time_score_node = TIME_SCORE_SCENE.instance()
#			time_score_node.shine_detail = mission_ids[mission_id]
#			time_score_node.time_score = time_score
#			time_scores_container.add_child(time_score_node)

## button functions

func play_level():
	start_level(false)

func edit_level():
	# it's probably better that save data from playing
	# doesn't leak into the editor (the file is left intact)
	CurrentLevelData.save_data.reset_save_data()
	start_level(true)

func copy_code():
	var code: String = level_list_util.get_level_code_from_id(level_id, working_folder)
	if OS.has_feature("JavaScript"):
		JavaScript.download_buffer(
			code.to_utf8(), 
			code + ".txt")
	else:
		OS.clipboard = code

func view_scores():
	var switch_to_scores: bool = (view_button.text == view_scores_text)
	
	view_button.text = view_info_text if switch_to_scores else view_scores_text
	
	view_time_icon.visible = !switch_to_scores
	info_tab.visible = !switch_to_scores
	
	view_info_icon.visible = switch_to_scores
	scores_tab.visible = switch_to_scores

func reset_save():
	CurrentLevelData.save_data.reset_save_data()

func delete_level():
	CurrentLevelData.save_data.reset_save_data()
	list_handler.remove_level(level_id)


func start_level(start_in_edit_mode : bool):
	if starting_level: return
	starting_level = true
	
	var selected_file = -2 if is_campaign else -1
	
	Singleton.SceneSwitcher.menu_return_screen = "LevelsList"
	Singleton.SceneSwitcher.menu_return_args = [level_metadata, level_id, working_folder, can_edit, is_campaign]
	Singleton.SceneSwitcher.start_level(level_metadata, level_id, working_folder, start_in_edit_mode, false, get_hub_level(), true, true, selected_file)


func get_hub_level() -> String:
	if is_campaign:
		var info_dict: Dictionary = campaign_info_util.load_info_file(working_folder)
		return info_dict.get("hub_level", "")
	else:
		return ""
