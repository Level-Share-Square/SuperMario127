extends HTTPRequest


signal login_request_completed(result, response_code, headers, body)
signal rating_request_completed(result, response_code, headers, body)

signal comment_request_completed(result, response_code, headers, body)
signal edit_request_completed(result, response_code, headers, body)
signal delete_request_completed(result, response_code, headers, body)
signal react_request_completed(result, response_code, headers, body)

signal reply_request_completed(result, response_code, headers, body, comment_id)
signal edit_reply_request_completed(result, response_code, headers, body)
signal delete_reply_request_completed(result, response_code, headers, body)

onready var account_info: AccountInfo = $"%AccountInfo"


func login(email: String, password: String):
	var headers: PoolStringArray = [
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"email" : email, 
		"password": password
	})
	
	var error: int = request(
		"https://levelsharesquare.com/api/users/login", 
		headers, 
		true, 
		HTTPClient.METHOD_POST, 
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")
	
	connect("request_completed", self, "login_request_completed", [], CONNECT_ONESHOT)


func login_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("login_request_completed", result, response_code, headers, body)
	if response_code == 200:
		var info: Dictionary = JSON.parse(body.get_string_from_utf8()).result
		account_info.id = info.result._id
		account_info.username = info.result.username
		account_info.icon_url = info.result.avatar
		account_info.token = info.token
		
		account_info.login()
		account_info.save_info()



func play_level(level_id: String):
	var header: PoolStringArray = [
		"Authorization: Bearer " + account_info.token
	]
	var body: String = JSON.print({
		"levelID" : level_id
	})
	
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/play", 
		header, 
		true, 
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")



func submit_rating(level_id: String, new_rate: float):
	var header: PoolStringArray = [
		"Authorization: Bearer " + account_info.token, 
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"starRate": new_rate
	})
	
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/rate", 
		header,
		true, 
		HTTPClient.METHOD_PATCH, 
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")
	
	connect("request_completed", self, "rating_request_completed", [], CONNECT_ONESHOT)


func rating_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("rating_request_completed", result, response_code, headers, body)



func post_comment(level_id: String, text: String):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token, 
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"level": level_id, 
		"author": account_info.id, 
		"content": text
	})
	
	print("posting ", level_id, ", ", text)
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comment",
		headers,
		true,
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")

	connect("request_completed", self, "comment_request_completed", [], CONNECT_ONESHOT)


func edit_comment(level_id: String, comment_id: String, text: String):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token, 
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"content": text
	})
	
	print(account_info.id, ", ", account_info.token)
	print("editing ", level_id, ", ", comment_id, ", ", text)
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comments/" + comment_id + "/edit?type=level_comment",
		headers,
		true,
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")

	connect("request_completed", self, "edit_request_completed", [], CONNECT_ONESHOT)


func delete_comment(level_id: String, comment_id: String):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token
	]
	
	print("deleting ", level_id, ", ", comment_id)
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comments/" + comment_id + "/delete?type=level_comment",
		headers,
		true,
		HTTPClient.METHOD_PATCH
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")
	
	connect("request_completed", self, "delete_request_completed", [], CONNECT_ONESHOT)


func react_comment(level_id: String, comment_id: String, is_like: bool):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token, 
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"reaction": "like" if is_like else "dislike"
	})
	
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comments/" + comment_id + "/react",
		headers,
		true,
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")
	
	connect("request_completed", self, "react_request_completed", [], CONNECT_ONESHOT)


func comment_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("comment_request_completed", result, response_code, headers, body)

func edit_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("edit_request_completed", result, response_code, headers, body)

func delete_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("delete_request_completed", result, response_code, headers, body)

func react_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("react_request_completed", result, response_code, headers, body)



func post_reply(level_id: String, comment_id: String, text: String):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token, 
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"level": level_id, 
		"author": account_info.id, 
		"content": text
	})
	
	print("posting reply ", level_id, ", ", text)
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comments/" + comment_id + "/create",
		headers,
		true,
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")

	connect("request_completed", self, "reply_request_completed", [comment_id], CONNECT_ONESHOT)


func edit_reply(level_id: String, comment_id: String, reply_id: String, text: String):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token, 
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var body: String = JSON.print({
		"content": text
	})
	
	print(account_info.id, ", ", account_info.token)
	print("editing reply ", level_id, ", ", comment_id, ", ", reply_id, ", ", text)
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comments/replies/" + reply_id + "/edit?type=level_reply",
		headers,
		true,
		HTTPClient.METHOD_PATCH,
		body
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")

	connect("request_completed", self, "edit_reply_request_completed", [], CONNECT_ONESHOT)


func delete_reply(level_id: String, comment_id: String, reply_id: String):
	var headers: PoolStringArray = [
		"Authorization: Bearer " + account_info.token
	]
	
	print("deleting reply ", level_id, ", ", comment_id)
	var error: int = request(
		"https://levelsharesquare.com/api/levels/" + level_id + "/comments/" + comment_id + "/replies/" + reply_id + "/delete?type=level_reply",
		headers,
		true,
		HTTPClient.METHOD_PATCH
	)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")
	
	connect("request_completed", self, "delete_reply_request_completed", [], CONNECT_ONESHOT)


func reply_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, comment_id: String = ""):
	print(JSON.parse(body.get_string_from_utf8()).result)
	emit_signal("reply_request_completed", result, response_code, headers, body, comment_id)

func edit_reply_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("edit_reply_request_completed", result, response_code, headers, body)

func delete_reply_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("delete_reply_request_completed", result, response_code, headers, body)
