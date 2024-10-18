extends HTTPRequest


onready var comments = $"%Comments"
onready var http_images = $"%HTTPImages"

var level_id: String
var comment_id: String

var reply_stack: Array


func load_replies(_comment_id: String, page: int = 1):
	comment_id = _comment_id
	
	print("Requesting replies for comment id ", comment_id, "...")
	var error: int = request("https://levelsharesquare.com/api/levels/" + level_id + "/comments/" + comment_id + "?threadpage=" + str(page))
	if error != OK:
		printerr("An error occurred while making an HTTP request.")


func load_comments(_level_id: String, page: int = 1):
	level_id = _level_id
	
	cancel_request()
	if page <= 1:
		comments.clear_children()
	
	print("Requesting comments for level id ", level_id, "...")
	var error: int = request("https://levelsharesquare.com/api/levels/" + level_id + "/comments?page=" + str(page))
	if error != OK:
		printerr("An error occurred while making an HTTP request.")


func request_completed(result, response_code, headers, body):
	if response_code != 200: 
		printerr("Failed to connect to Level Share Square. Response code: " + str(response_code))
		return
	
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	var is_reply: bool
	
	if json.result.has("levelComments"):
		for comment in json.result.levelComments:
			var comment_info := LSSComment.new(comment)
			comments.add_comment(comment_info)
			if comment.has("replies") and comment.replies.size() > 0:
				reply_stack.append(comment_info.comment_id)
	else:
		is_reply = true
		for reply in json.result.levelCommentReplies:
			var reply_info := LSSComment.new(reply)
			comments.add_reply(reply_info, comment_id)
	
	
	print("Comments loaded.")
	if json.result.currentPage < json.result.numberOfPages:
		if is_reply:
			load_replies(comment_id, json.result.currentPage + 1)
		else:
			load_comments(level_id, json.result.currentPage + 1)
	elif reply_stack.size() > 0:
		load_replies(reply_stack.pop_front())
	else:
		http_images.call_deferred("load_next_image")
