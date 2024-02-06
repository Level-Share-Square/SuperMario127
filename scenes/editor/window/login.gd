extends Control


onready var httpreq = get_parent().get_node("HTTPRequest")
onready var email = $Username
onready var password = $Password
onready var button = get_parent().get_node("LoginButton")
onready var buttonhelp = get_parent().get_node("HelpButton")
onready var wrong = get_parent().get_node("Title2")


# Called when the node enters the scene tree for the first time.
func _ready():
	wrong.hide()
	httpreq.connect("request_completed", self, "on_req_complete")
	button.connect("button_down", self, "on_login_pressed")
	buttonhelp.connect("button_down", self, "on_help_pressed")
	
func on_help_pressed():
	get_parent().get_parent().get_node("HelpWindow").open()
	
func on_login_pressed():
	var dic = {"email" : email.text, "password": password.text}
	var body = JSON.print(dic)
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var result = httpreq.request("https://levelsharesquare.com/api/users/login", headers, true, 2, body)

func on_req_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	if response_code != 200:
		wrong.show()
		yield(get_tree().create_timer(3), "timeout")
		wrong.hide()
	else:
		UserInfo.username = json.result["result"]["username"]
		UserInfo.icon = json.result["result"]["avatar"]
		UserInfo.token = json.result["result"]["token"]
		get_parent().get_parent().button_login.text = "Logged in as " + UserInfo.username
		get_parent().close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
