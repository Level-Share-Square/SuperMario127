extends PanelContainer


signal level_loaded(page_info)


const CHECKED_COLOR := Color("aee3ff")
const TAG_SCENE := preload("res://scenes/menu/level_portal/level_panel/tag.tscn")
const DEFAULT_THUMB := preload("res://scenes/menu/level_portal/default_thumb.png")
const DEFAULT_ICON := preload("res://scenes/menu/level_portal/default_icon.png")

const UNSAVED_TEXT := "Save"
const SAVED_TEXT := "Saved"

const UNFAVORITED_TEXT := "Favorite?"
const FAVORITED_TEXT := "Favorited."


onready var outdated_version = $"%OutdatedVersion"
onready var level_buttons = $"%LevelButtons"
onready var save_button = $"%SaveButton"
onready var favorite_button = $"%FavoriteButton"

onready var level_title = $"%LevelTitle"
onready var title_shadow = level_title.get_node("Shadow")

onready var author_icon = $"%AuthorIcon"
onready var author_name = $"%AuthorName"

onready var description = $"%Description"


onready var ratings_outline = $"%StarOutline"
onready var ratings_bar = $"%Stars"

onready var green_ratings_outline = $"%GreenStarOutline"
onready var green_ratings_bar = $"%GreenStars"

onready var thumbnail = $"%Thumbnail"

onready var plays_label = $"%PlaysLabel"
onready var favorites_label = $"%FavoritesLabel"
onready var rates_label = $"%RatesLabel"
onready var time_label = $"%TimeLabel"

onready var plays_container = $"%PlaysContainer"
onready var favorites_container = $"%FavoritesContainer"
onready var rates_container = $"%RatesContainer"

onready var tags = $"%Tags"


onready var shines_label = $"%ShinesLabel"
onready var coins_label = $"%CoinsLabel"


onready var http_account = $"%HTTPAccount"
onready var account_info = $"%AccountInfo"

onready var http_request = $"%HTTPRequest"
onready var http_images = $"%HTTPImages"
var page_info: LSSLevelPage

var level_version_map: Dictionary = {
	101: "0.10.0",
}

func load_level(_page_info: LSSLevelPage):
	page_info = _page_info
	
	
	level_title.text = page_info.level_name
	title_shadow.text = level_title.text
	
	author_name.text = page_info.author_name
	description.set_description(page_info.description)
	
	
	ratings_bar.value = page_info.rating
	green_ratings_bar.value = page_info.rating
	
	var is_green: bool = (page_info.rating >= 4.5)
	var is_visible: bool = (page_info.rating > 0)
	green_ratings_outline.visible = is_green and is_visible
	ratings_outline.visible = not is_green and is_visible
	
	plays_label.text = str(page_info.plays)
	favorites_label.text = str(page_info.favorites)
	rates_label.text = str(page_info.rates)
	
	time_label.text = page_info.timestamp.left(10).right(2)
	
	plays_container.modulate = CHECKED_COLOR if page_info.has_played else Color.white 
	rates_container.modulate = CHECKED_COLOR if page_info.has_rated > 0 else Color.white 
	
	
	var thumb_texture: ImageTexture = http_images.get_cached_image(page_info.thumbnail_url)
	if thumb_texture != null:
		thumbnail.texture = thumb_texture
	else:
		thumbnail.texture = DEFAULT_THUMB
		if page_info.thumbnail_url != "":
			http_images.image_queue.append(page_info.thumbnail_url)
	
	var icon_texture: ImageTexture = http_images.get_cached_image(page_info.author_icon_url)
	if icon_texture != null:
		author_icon.texture = icon_texture
	else:
		author_icon.texture = DEFAULT_ICON
		if page_info.author_icon_url != "":
			http_images.image_queue.append(page_info.author_icon_url)
	
	http_images.load_next_image()
	
	
	for child in tags.get_children():
		child.call_deferred("queue_free")
	
	for tag in page_info.tags:
		var tag_node = TAG_SCENE.instance()
		tag_node.text = tag
		tags.call_deferred("add_child", tag_node)
	
	
	save_button.disabled = lss_link_util.is_level_in_link(page_info.level_id)
	save_button.text = SAVED_TEXT if save_button.disabled else UNSAVED_TEXT
	
	var version_comparison: int = conversion_util.compare_versions(
		page_info.level_version, 
		level_version_map.get(ProjectSettings.get_setting("global/level_code_version")))
	
	outdated_version.visible = (version_comparison > 0)
	level_buttons.visible = (version_comparison <= 0)
	if version_comparison <= 0 and page_info.shine_count >= 0 and page_info.star_coin_count >= 0:
		shines_label.text = str(page_info.shine_count)
		coins_label.text = str(page_info.star_coin_count)
	else:
		shines_label.text = "N/A"
		coins_label.text = "N/A"
	
	emit_signal("level_loaded", page_info)
	
	favorite_button.visible = false


func image_loaded(url: String, texture: ImageTexture):
	if texture == null: return
	if not is_instance_valid(page_info): return
	
	match url:
		page_info.thumbnail_url:
			thumbnail.texture = texture
			
		page_info.author_icon_url:
			author_icon.texture = texture


## level buttons
func open_website():
	if not is_instance_valid(page_info): return
	OS.shell_open("https://levelsharesquare.com/levels/" + page_info.level_id)


func save_level():
	if lss_link_util.is_level_in_link(page_info.level_id): return
	
	var local_id: String = level_list_util.generate_level_id()
	var level_path: String = level_list_util.get_level_file_path(
		local_id,
		level_list_util.BASE_FOLDER)
	
	if page_info.level_code.substr(0, 2) != "[{": page_info.level_code = CurrentLevelData.convert_old_code_to_new(page_info.level_code)
		
	level_list_util.save_level_code_file(page_info.level_code, level_path)
	sort_file_util.add_to_sort(local_id, level_list_util.BASE_FOLDER, sort_file_util.LEVELS)
	
	lss_link_util.add_level_to_link(page_info.level_id, level_path)
	
	save_button.disabled = true
	save_button.text = SAVED_TEXT
	
	Singleton.SceneSwitcher.reload_base_folder = true
	if account_info.logged_in:
		http_account.play_level(page_info.level_id)


func play_level():
	save_level()
	
	var level_path: String = lss_link_util.get_path_from_id(page_info.level_id)
	var local_id: String = level_path.get_file().get_basename()
	var working_folder: String = level_path.get_base_dir()
	
	CurrentLevelData.unload_all_areas()
	
	if page_info.level_code.substr(0, 2) != "[{": page_info.level_code = CurrentLevelData.convert_old_code_to_new(page_info.level_code)
	
	var page_return_vars: Dictionary
	for variable in http_request.return_args:
		page_return_vars[variable] = http_request[variable]
	
	Singleton.SceneSwitcher.menu_return_screen = "LevelPortal"
	Singleton.SceneSwitcher.menu_return_args = [page_info.level_id, page_return_vars]
	
	Singleton.SceneSwitcher.start_level(LevelCodeDeserializer.deserialize_level_metadata_code(LevelCodeTokenizer.splice_metadata(page_info.level_code)), local_id, working_folder, false)


## adding descriptions, author, thumbnail
var keys_defaults: Array = [
	["name", "level_name", CurrentLevelData.DEFAULT_NAME],
	["description", "description", CurrentLevelData.DEFAULT_DESCRIPTION],
	["author", "author_name", CurrentLevelData.DEFAULT_AUTHOR],
	["thumbnail_url", "thumbnail_url", CurrentLevelData.DEFAULT_THUMBNAIL_URL]
]
