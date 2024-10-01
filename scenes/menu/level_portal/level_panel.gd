extends PanelContainer


const TAG_SCENE := preload("res://scenes/menu/level_portal/level_panel/tag.tscn")
const DEFAULT_THUMB := preload("res://scenes/menu/level_portal/default_thumb.png")
const DEFAULT_ICON := preload("res://assets/misc/icon.png")


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

onready var tags = $"%Tags"


onready var shines_label = $"%ShinesLabel"
onready var coins_label = $"%CoinsLabel"


onready var http_images = $"%HTTPImages"
var page_info: LSSLevelPage


func load_level(_page_info: LSSLevelPage):
	page_info = _page_info
	
	level_title.text = page_info.level_name
	title_shadow.text = level_title.text
	
	author_name.text = page_info.author_name
	description.set_description(page_info.description)
	
	
	var is_green: bool = (page_info.rating >= 4.5)
	var is_visible: bool = (page_info.rating > 0)
	green_ratings_outline.visible = is_green and is_visible
	ratings_outline.visible = not is_green and is_visible
	
	plays_label.text = str(page_info.plays)
	favorites_label.text = str(page_info.favorites)
	rates_label.text = str(page_info.rates)
	
	time_label.text = page_info.timestamp.left(10).right(2)
	
	
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
	
	
	page_info.level_info.load_in()
	
	var collectible_counts = page_info.level_info.get_collectible_counts()
	shines_label.text = str(collectible_counts["total_shines"])
	coins_label.text = str(collectible_counts["total_star_coins"])


func image_loaded(url: String, texture: ImageTexture):
	if texture == null: return
	if not is_instance_valid(page_info): return
	
	match url:
		page_info.thumbnail_url:
			thumbnail.texture = texture
			
		page_info.author_icon_url:
			author_icon.texture = texture
