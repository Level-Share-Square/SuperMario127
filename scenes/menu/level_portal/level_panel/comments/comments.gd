extends VBoxContainer


const COMMENT_SCENE := preload("res://scenes/menu/level_portal/level_panel/comments/comment.tscn")
const COMMENT_CONTENT_SCENE := preload("res://scenes/menu/level_portal/level_panel/comments/comment_content.tscn")
onready var http_images = $"%HTTPImages"


func clear_children():
	for child in get_children():
		child.call_deferred("queue_free")


func add_comment(comment_info: LSSComment):
	var comment_node: Control = COMMENT_SCENE.instance()
	var comment_content: Control = comment_node.get_node("%Content")
	comment_node.name = comment_info.comment_id
	
	comment_content.http_images = http_images
	http_images.connect("image_loaded", comment_content, "image_loaded")
	
	call_deferred("add_child", comment_node)
	comment_content.call_deferred("load_info", comment_info)


func add_reply(reply_info: LSSComment, comment_id: String):
	var comment_node: Control = get_node_or_null(comment_id)
	if not is_instance_valid(comment_node): return
	
	var replies: Control = comment_node.get_node("%Replies")
	var reply_box: Control = comment_node.get_node("%ReplyBox")
	var comment_content: Control = COMMENT_CONTENT_SCENE.instance()
	
	comment_content.http_images = http_images
	http_images.connect("image_loaded", comment_content, "image_loaded")
	
	replies.visible = true
	reply_box.call_deferred("add_child", comment_content)
	comment_content.call_deferred("load_info", reply_info)
	comment_content.call_deferred("hide_votes")
