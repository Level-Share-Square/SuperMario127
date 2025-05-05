extends Control


onready var httpreq = get_parent().get_node("HTTPRequest")
onready var httpreq2 = get_parent().get_node("HTTPRequest2")
onready var email = $Username
onready var password = $Password
onready var button = get_parent().get_node("LoginButton")
onready var buttonhelp = get_parent().get_node("HelpButton")
onready var wrong = get_parent().get_node("Title2")
onready var visibility = get_parent().get_node("Visible")

onready var on = preload("res://assets/misc/open_eye.png")
onready var off = preload("res://assets/misc/closed_eye.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	password.secret
	visibility.texture_normal = off
	wrong.hide()
	visibility.connect("button_down", self, "on_visible_pressed")
	httpreq.connect("request_completed", self, "on_req_complete")
	button.connect("button_down", self, "on_login_pressed")
	buttonhelp.connect("button_down", self, "on_help_pressed")
	
func on_help_pressed():
	get_parent().get_parent().get_node("HelpWindow").open()
	
	
func on_visible_pressed():
	password.secret = !password.secret
	if password.secret:
		visibility.texture_normal = off
	else:
		visibility.texture_normal = on
	
func on_login_pressed():
	var dic = {"email" : email.text, "password": password.text}
	var body = JSON.print(dic)
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var result = httpreq.request("https://levelsharesquare.com/api/users/login", headers, true, 2, body)

func on_req_complete(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	if response_code != 200:
		wrong.show()
		yield(get_tree().create_timer(3), "timeout")
		wrong.hide()
	else:
		UserInfo.logged_out = false
		UserInfo.id = json.result["result"]["_id"]
		UserInfo.username = json.result["result"]["username"]
		UserInfo.icon = json.result["result"]["avatar"]
		UserInfo.token = json.result["token"]
		UserInfo.save_info()
		httpreq2.connect("request_completed", self, "on_req2_complete")
		var header = ["Authorization: Bearer " + UserInfo.token]
		var resul = httpreq2.request("https://levelsharesquare.com/api/app/intervals/SM127", header, true, 2, "")
		get_parent().get_parent().button_login.text = "Logged in as " + UserInfo.username
		get_parent().close()
	
	
func on_req2_complete(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	print(response_code)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
