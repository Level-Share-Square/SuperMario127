extends Control


const TIME_SCORE_SCENE: PackedScene = preload("res://scenes/menu/levels_list/level_panel/time_score.tscn")

onready var list_handler = $"%ListHandler"
onready var http_thumbnails = $"%HTTPThumbnails"

var working_folder: String
var level_id: String
var level_info: LevelInfo

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

### time scores
onready var time_scores_container: VBoxContainer = $ScoresTab/Panel/ScrollContainer/MarginContainer/VBoxContainer

func load_level_info(_level_info: LevelInfo, _level_id: String, _working_folder: String):
	yield(get_parent(), "screen_opened")
	
	level_info = _level_info
	level_id = _level_id
	working_folder = _working_folder
	
	# load the real level data now
	level_info.load_in()
	
	title.text = level_info.level_name
	title_shadow.text = title.text
	
	author.text = author_prefix + level_info.level_author
	description.bbcode_text = "[center]" + level_info.level_description + "[/center]"
	
	# thumbnail
	var cached_image: ImageTexture = http_thumbnails.get_cached_image(level_info.thumbnail_url)
	if cached_image == null:
		thumbnail.texture = level_info.get_level_background_texture()
		
		foreground.visible = true
		foreground.modulate = level_info.get_level_background_modulate()
		foreground.texture = level_info.get_level_foreground_texture()
	else:
		thumbnail.texture = cached_image
		foreground.visible = false
	
	
	# load save file
	var save_path: String = level_list_util.get_level_save_path(level_id, working_folder)
	if level_list_util.file_exists(save_path):
		level_info.load_save_from_dictionary(level_list_util.load_level_save_file(save_path))
	load_time_scores()
	
	var collectible_counts = level_info.get_collectible_counts()
	
	var total_shine_count: int = collectible_counts["total_shines"]
	var collected_shine_count: int = collectible_counts["collected_shines"]
	
	shine_label.text = str(collected_shine_count) + "/" + str(total_shine_count)
	shine_label.modulate = completion_color if (collected_shine_count >= total_shine_count) else Color.white
	
	var total_star_coin_count: int = collectible_counts["total_star_coins"]
	var collected_star_coin_count: int = collectible_counts["collected_star_coins"]
	
	star_coin_label.text = str(collected_star_coin_count) + "/" + str(total_star_coin_count)
	star_coin_label.modulate = completion_color if (collected_star_coin_count >= total_star_coin_count) else Color.white
	
	
	# these are floats cuz they need to be divided for some calculations :)
	var total_collectibles: float = collectible_counts["total_collectibles"]
	var total_collected: float = collectible_counts["total_collected"]
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
	
	var time_scores = level_info.time_scores.values()
	var shine_details_sorted = ([] + level_info.shine_details)
	shine_details_sorted.sort_custom(LevelInfo, "shine_sort")
	
	for shine_detail in shine_details_sorted:
		var time_score = time_scores[
			shine_detail.id if (shine_detail.id < time_scores.size()) else (time_scores.size() - 1)
		]
		
		var time_score_node = TIME_SCORE_SCENE.instance()
		time_score_node.shine_detail = shine_detail
		time_score_node.time_score = time_score
		time_scores_container.add_child(time_score_node)

## button functions

func play_level():
	start_level(false)

func edit_level():
	# it's probably better that save data from playing
	# doesn't leak into the editor (the file is left intact)
	level_info.reset_save_data(false)
	start_level(true)

func copy_code():
	if OS.has_feature("JavaScript"):
		JavaScript.download_buffer(
			level_info.level_code.to_utf8(), 
			level_info.level_name + ".txt")
	else:
		OS.clipboard = str(level_info.level_code)

func view_scores():
	var switch_to_scores: bool = (view_button.text == view_scores_text)
	
	view_button.text = view_info_text if switch_to_scores else view_scores_text
	
	view_time_icon.visible = !switch_to_scores
	info_tab.visible = !switch_to_scores
	
	view_info_icon.visible = switch_to_scores
	scores_tab.visible = switch_to_scores

func reset_save():
	level_info.reset_save_data()

func delete_level():
	reset_save()
	list_handler.remove_level(level_id)


func start_level(start_in_edit_mode : bool):
	Singleton.SceneSwitcher.menu_return_screen = "LevelsList"
	Singleton.SceneSwitcher.menu_return_args = [working_folder]
	Singleton.SceneSwitcher.start_level(level_info, level_id, working_folder, start_in_edit_mode, true)
