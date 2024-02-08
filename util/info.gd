extends Node

var id = ""
var username = ""
var icon = ""
var token = ""

var logged_out = true

var ping_timer = 0

onready var httpreq = HTTPRequest.new()

func save_info():
	var file = File.new()
	var token = UserInfo.token
	file.open("user://LSS.login", File.WRITE)
	file.store_var(UserInfo.id)
	file.store_var(UserInfo.username)
	file.store_var(UserInfo.icon)
	file.store_var(token)

func _ready():
	add_child(httpreq)
	httpreq.connect("request_completed", self, "ping_complete")
	var file = File.new()
	if file.file_exists("user://LSS.login"):
		file.open("user://LSS.login", File.READ)
		id = file.get_var()
		username = file.get_var()
		icon = file.get_var()
		token = file.get_var()
		

func _physics_process(delta):
	if token != "" && ping_timer <= 0:
		var header = ["Authorization: Bearer " + token]
		httpreq.request("https://levelsharesquare.com/api/app/intervals/SM127", header, true, 2, "")
		ping_timer = 60
	if ping_timer >= 0:
		ping_timer -= delta
		
func ping_complete(result, response_code, headers, body):
	if response_code == 400:
		logged_out = true
		id = ""
		username = ""
		icon = ""
		token = ""
		save_info()
	else:
		logged_out = false
