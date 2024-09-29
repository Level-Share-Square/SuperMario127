extends Control


const TAG_SEPARATOR: String = ", "

onready var name_label = $"%NameLabel"
onready var thumbnail = $"%Thumbnail"

onready var ratings_outline = $"%StarOutline"
onready var ratings_bar = $"%Stars"

onready var green_ratings_outline = $"%GreenStarOutline"
onready var green_ratings_bar = $"%GreenStars"

onready var author_label = $"%AuthorLabel"
onready var tags_label = $"%TagsLabel"

onready var favorites_label = $"%FavoritesLabel"
onready var plays_label = $"%PlaysLabel"
onready var comments_label = $"%CommentsLabel"

var level_info: LSSLevelInfo
var texture: ImageTexture


func _ready():
	set_style()


func set_style():
	name_label.text = level_info.level_name
	author_label.text = level_info.author_name
	
	ratings_bar.value = level_info.rating
	green_ratings_bar.value = level_info.rating
	
	var is_green: bool = (level_info.rating >= 4.5)
	var is_visible: bool = (level_info.rating > 0)
	green_ratings_outline.visible = is_green and is_visible
	ratings_outline.visible = not is_green and is_visible
	
	
	tags_label.text = ""
	for tag in level_info.tags:
		tags_label.text += tag
		tags_label.text += TAG_SEPARATOR
	tags_label.text = tags_label.text.trim_suffix(TAG_SEPARATOR)
	
	favorites_label.text = str(level_info.favorites)
	plays_label.text = str(level_info.plays)
	comments_label.text = str(level_info.comments)
	
	
	if texture != null:
		thumbnail.texture = texture


func thumbnail_loaded(level_id: String, _texture: ImageTexture):
	if level_id != level_info.level_id: return
	texture = _texture
	thumbnail.texture = texture
