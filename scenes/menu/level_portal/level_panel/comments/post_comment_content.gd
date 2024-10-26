extends VBoxContainer


const DEFAULT_ICON := preload("res://scenes/menu/level_portal/default_icon.png")


onready var author_icon = $"%AuthorIcon"
onready var author_name = $"%AuthorName"
onready var content = $"%Content"

onready var info = $"%Info"
onready var edit = $"%Edit"
onready var sending = $"%Sending"

var http_images: HTTPRequest
var http_account: HTTPRequest
var account_info: AccountInfo

var level_id: String


func load_info(_account_info: AccountInfo, body: String = ""):
	account_info = _account_info
	content.text = body
	
	author_name.text = account_info.username
	var icon_texture: ImageTexture = http_images.get_cached_image(account_info.icon_url)
	if icon_texture != null:
		author_icon.texture = icon_texture
	else:
		author_icon.texture = DEFAULT_ICON


func post_comment():
	http_account.post_comment(level_id, content.text)
	content.text = ""
	
	if not http_account.is_connected("comment_request_completed", self, "request_completed"):
		http_account.connect("comment_request_completed", self, "request_completed")
	
	info.hide()
	edit.hide()
	sending.show()


func request_completed(_result: int, _response_code: int, _headers: PoolStringArray, _body: PoolByteArray):
	info.show()
	edit.show()
	sending.hide()
