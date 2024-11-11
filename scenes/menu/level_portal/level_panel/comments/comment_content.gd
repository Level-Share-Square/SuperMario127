extends VBoxContainer

const LIKE_TEXT: String = " Like "
const LIKED_TEXT: String = " Liked "

const DISLIKE_TEXT: String = " Dislike "
const DISLIKED_TEXT: String = " Disliked "

const DEFAULT_ICON := preload("res://scenes/menu/level_portal/default_icon.png")

onready var author_icon = $"%AuthorIcon"
onready var author_name = $"%AuthorName"
onready var content = $"%Content"

onready var votes = $"%Votes"
onready var likes = $"%Likes"
onready var dislikes = $"%Dislikes"
onready var timestamp = $"%Timestamp"

onready var like_button = $"%LikeButton"
onready var dislike_button = $"%DislikeButton"
onready var edit = $"%Edit"

var http_images: HTTPRequest
var http_account: HTTPRequest
var comment_info: LSSComment

var account_info: AccountInfo
var post_content: VBoxContainer

var level_id: String
var parent_id: String

export var is_reply: bool

func hide_votes():
	votes.visible = false


func load_account(_account_info: AccountInfo, _http_account: HTTPRequest, _post_content: VBoxContainer, set_text: bool = true):
	account_info = _account_info
	http_account = _http_account
	post_content = _post_content
	
	if account_info.logged_in:
		update_reacts_text(comment_info.user_likes, comment_info.user_dislikes)
		if comment_info.author_id == account_info.id:
			edit.visible = true
		else:
			like_button.disabled = false
			dislike_button.disabled = false
	
	post_content.http_images = http_images
	post_content.http_account = http_account
	
	post_content.level_id = level_id
	if not is_reply:
		post_content.comment_id = comment_info.comment_id
	else:
		post_content.comment_id = parent_id
		post_content.reply_id = comment_info.comment_id
	
	post_content.load_info(account_info, comment_info.content if set_text else "")


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


## reactions
func react_comment(is_like: bool):
	like_button.disabled = true
	dislike_button.disabled = true
	
	http_account.react_comment(level_id, comment_info.comment_id, is_like)
	if not http_account.is_connected("react_request_completed", self, "request_completed"):
		http_account.connect("react_request_completed", self, "request_completed", [], CONNECT_ONESHOT)


func request_completed(_result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray):
	like_button.disabled = false
	dislike_button.disabled = false
	
	if response_code == 200:
		var dict: Dictionary = JSON.parse(body.get_string_from_utf8()).result
		update_reacts_text(dict.likes, dict.dislikes)


func update_reacts_text(likes_array: PoolStringArray, dislikes_array: PoolStringArray):
	likes.text = str(likes_array.size())
	dislikes.text = str(dislikes_array.size())
	
	if account_info.logged_in:
		like_button.text = LIKED_TEXT if account_info.id in likes_array else LIKE_TEXT
		dislike_button.text = DISLIKED_TEXT if account_info.id in dislikes_array else DISLIKE_TEXT
