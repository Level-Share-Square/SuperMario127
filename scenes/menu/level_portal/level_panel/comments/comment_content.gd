extends VBoxContainer


const DEFAULT_ICON := preload("res://assets/misc/icon.png")


onready var author_icon = $"%AuthorIcon"
onready var author_name = $"%AuthorName"
onready var content = $"%Content"

onready var votes = $"%Votes"
onready var likes = $"%Likes"
onready var dislikes = $"%Dislikes"
onready var timestamp = $"%Timestamp"


var http_images: HTTPRequest
var comment_info: LSSComment


func hide_votes():
	votes.visible = false


func load_info(_comment_info: LSSComment):
	comment_info = _comment_info
	
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
