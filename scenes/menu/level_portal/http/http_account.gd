extends HTTPRequest


signal login_request_completed(result, response_code, headers, body)
signal rating_request_completed(result, response_code, headers, body)
signal comment_request_completed(result, response_code, headers, body)

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
		"level" : level_id, 
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


func comment_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	emit_signal("comment_request_completed", result, response_code, headers, body)
