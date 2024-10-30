extends VBoxContainer


const DEFAULT_ICON := preload("res://scenes/menu/level_portal/default_icon.png")

signal post_completed

signal edit_completed
signal edit_successful(new_text)

signal deletion_successful
signal deletion_unsuccessful

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
var comment_id: String
var reply_id: String

export var is_reply: bool


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
	if content.text.strip_edges() == "": return
	
	if not is_reply:
		http_account.post_comment(level_id, content.text)
		if not http_account.is_connected("comment_request_completed", self, "request_completed"):
			http_account.connect("comment_request_completed", self, "request_completed", [0])
	else:
		http_account.post_reply(level_id, comment_id, content.text)
		if not http_account.is_connected("reply_request_completed", self, "request_completed"):
			http_account.connect("reply_request_completed", self, "reply_request_completed")
	
	content.text = ""
	info.hide()
	edit.hide()
	sending.show()


func edit_comment():
	if content.text.strip_edges() == "": return
	
	if not is_reply:
		http_account.edit_comment(level_id, comment_id, content.text)
		if not http_account.is_connected("edit_request_completed", self, "request_completed"):
			http_account.connect("edit_request_completed", self, "request_completed", [1])
	else:
		http_account.edit_reply(level_id, comment_id, reply_id, content.text)
		if not http_account.is_connected("edit_reply_request_completed", self, "request_completed"):
			http_account.connect("edit_reply_request_completed", self, "request_completed", [1])
	
	info.hide()
	edit.hide()
	sending.show()


func delete_comment():
	if not is_reply:
		http_account.delete_comment(level_id, comment_id)
		if not http_account.is_connected("delete_request_completed", self, "request_completed"):
			http_account.connect("delete_request_completed", self, "request_completed", [2])
	else:
		http_account.delete_reply(level_id, comment_id, reply_id)
		if not http_account.is_connected("delete_reply_request_completed", self, "request_completed"):
			http_account.connect("delete_reply_request_completed", self, "request_completed", [2])
	
	info.hide()
	edit.hide()
	sending.show()


func reply_request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray, comment_id: String):
	info.show()
	edit.show()
	sending.hide()
	emit_signal("post_completed")

func request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray, request_type: int):
	info.show()
	edit.show()
	sending.hide()
	
	match (request_type):
		0:
			emit_signal("post_completed")
		1: # edit
			emit_signal("edit_completed")
			if response_code == 200 or response_code == 201:
				emit_signal("edit_successful", content.text)
		2: # deletion
			if response_code == 200 or response_code == 201:
				emit_signal("deletion_successful")
			else:
				emit_signal("deletion_unsuccessful")
