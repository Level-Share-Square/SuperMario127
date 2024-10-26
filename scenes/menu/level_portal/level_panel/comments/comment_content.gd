extends VBoxContainer


const DEFAULT_ICON := preload("res://scenes/menu/level_portal/default_icon.png")


onready var author_icon = $"%AuthorIcon"
onready var author_name = $"%AuthorName"
onready var content = $"%Content"

onready var votes = $"%Votes"
onready var likes = $"%Likes"
onready var dislikes = $"%Dislikes"
onready var timestamp = $"%Timestamp"

onready var edit = $"%Edit"

var http_images: HTTPRequest
var comment_info: LSSComment

var account_info: AccountInfo
var post_content: VBoxContainer

var level_id: String


func hide_votes():
	votes.visible = false


func load_account(_account_info: AccountInfo, _post_content: VBoxContainer):
	account_info = _account_info
	post_content = _post_content
	
	if account_info.logged_in and comment_info.author_id == account_info.id:
		edit.visible = true
	
	post_content.http_images = http_images
	post_content.level_id = level_id
	post_content.load_info(account_info, comment_info.content)


func load_info(_comment_info: LSSComment, _level_id: String):
	comment_info = _comment_info
	level_id = _level_id
	
	content.bbcode_text = comment_info.content
	author_name.text = comment_info.author_name
	
	likes.text = str(comment_info.likes)
	dislikes.text = str(comment_info.dislikes)
	
	
	var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(comment_info.timestamp, false)
	var unix_timestamp: int = Time.get_unix_time_from_datetime_dict(datetime) + get_time_zone_difference()
	var timestamp_dict: Dictionary = Time.get_datetime_dict_from_unix_time(unix_timestamp)
	
	timestamp.text = (
		index_to_month(timestamp_dict.month) + " " +
		str(timestamp_dict.day) + ", " +
		str(timestamp_dict.year)
	)
	
	var hour: int = timestamp_dict.hour
	timestamp.text += " - "
	timestamp.text += str(hour) + ":" + str(timestamp_dict.minute).pad_zeros(2)
	
	
	var icon_texture: ImageTexture = http_images.get_cached_image(comment_info.author_icon_url)
	if icon_texture != null:
		author_icon.texture = icon_texture
	else:
		author_icon.texture = DEFAULT_ICON
		if comment_info.author_icon_url != "":
			http_images.image_queue.append(comment_info.author_icon_url)
	
	edit.visible = false


func image_loaded(url: String, texture: ImageTexture):
	if texture == null: return
	if not is_instance_valid(comment_info): return
	if url != comment_info.author_icon_url: return
	author_icon.texture = texture



## DATETIME STUFF
const TIME_OFFSET: int = 2
const months: Array = [
	"Jan", "Feb", "Mar", "Apr",
	"May", "Jun", "Jul", "Aug",
	"Sep", "Oct", "Nov", "Dec"
]


static func index_to_month(index: int) -> String:
	return months[index - 1]


static func get_time_zone_difference() -> int:
	var global_unix: int = Time.get_unix_time_from_datetime_string(
		Time.get_datetime_string_from_system(true))
	var local_unix: int = Time.get_unix_time_from_datetime_string(
		Time.get_datetime_string_from_system(false))
	return (local_unix - global_unix)
