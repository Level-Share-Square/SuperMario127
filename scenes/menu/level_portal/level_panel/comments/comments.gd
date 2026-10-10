extends VBoxContainer


const COMMENT_SCENE := preload("res://scenes/menu/level_portal/level_panel/comments/comment.tscn")
const COMBINED_CONTENT_SCENE := preload("res://scenes/menu/level_portal/level_panel/comments/combined_content.tscn")

onready var http_images = $"%HTTPImages"
onready var http_account = $"%HTTPAccount"
onready var account_info = $"%AccountInfo"

onready var post_comment = $"%PostComment"
onready var post_comment_content = $"%PostCommentContent"

var level_id: String



func page_loaded(_level_id: String):
	level_id = _level_id
	
	post_comment.visible = account_info.logged_in
	if account_info.logged_in:
		post_comment_content.http_images = http_images
		post_comment_content.http_account = http_account
		post_comment_content.level_id = level_id
		post_comment_content.load_info(account_info)


func clear_children():
	for child in get_children():
		child.call_deferred("queue_free")


func add_comment(comment_info: LSSComment, move_to_front: bool = false):
	var comment_node: Control = COMMENT_SCENE.instance()
	
	var combined_content: Control = comment_node.get_node("%CombinedContent")
	var comment_content: Control = combined_content.get_node("%Content")
	comment_node.name = comment_info.comment_id
	
	comment_content.http_images = http_images
	http_images.connect("image_loaded", comment_content, "image_loaded")
	
	call_deferred("add_child", comment_node)
	comment_content.call_deferred("load_info", comment_info, level_id)
	comment_content.call_deferred("load_account", account_info, http_account, combined_content.get_node("%PostContent"))
	comment_content.call_deferred("load_account", account_info, http_account, combined_content.get_node("%PostReply"), false)
	
	if move_to_front:
		call_deferred("move_child", comment_node, 0)


func add_reply(reply_info: LSSComment, comment_id: String):
	var comment_node: Control = get_node_or_null(comment_id)
	if not is_instance_valid(comment_node): return
	
	var replies: Control = comment_node.get_node("%Replies")
	var reply_box: Control = comment_node.get_node("%ReplyBox")
	
	var combined_content: Control = COMBINED_CONTENT_SCENE.instance()
	var comment_content: Control = combined_content.get_node("%Content")
	var post_content: Control = combined_content.get_node("%PostContent")
	comment_content.is_reply = true
	post_content.is_reply = true
	
	comment_content.http_images = http_images
	comment_content.account_info = account_info
	comment_content.parent_id = comment_id
	http_images.connect("image_loaded", comment_content, "image_loaded")
	
	replies.visible = true
	reply_box.call_deferred("add_child", combined_content)
	comment_content.call_deferred("load_info", reply_info, level_id)
	comment_content.call_deferred("load_account", account_info, http_account, post_content)
	comment_content.call_deferred("hide_votes")


func comment_added(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	if response_code == 201:
		var dict: Dictionary = JSON.parse(body.get_string_from_utf8()).result.newLevelComment
		
		var author_dict: Dictionary = {
			"_id": account_info.id,
			"username": account_info.username,
			"avatar": account_info.icon_url
		}
		dict.author = author_dict
		
		var comment_info := LSSComment.new(dict)
		add_comment(comment_info, true)
	else:
		printerr("Failure adding comment. Response code: ", response_code)

func reply_added(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, comment_id: String):
	if response_code == 201:
		var dict: Dictionary = JSON.parse(body.get_string_from_utf8()).result.newLevelCommentReply
		var reply_info := LSSComment.new(dict)
		add_reply(reply_info, comment_id)
	else:
		printerr("Failure adding reply. Response code: ", response_code)
