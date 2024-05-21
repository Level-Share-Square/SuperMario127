extends Control

var author_info : Dictionary = {}
var level_comment_info = {}

onready var anim = $AnimationPlayer
onready var httpreq1 = $HTTPRequest
onready var textedit = $PanelContainer2/TextEdit
onready var back = $"127BackButton"
onready var post = $"PostButton"
onready var label = $ScrollContainer/Label
onready var httpreq2 = $HTTPRequest2

func _process(delta):
	$PanelContainer2/buttonX.margin_left = 220

# Called when the node enters the scene tree for the first time.
func _ready():
	back.connect("button_down", self, "back_pressed")
	post.connect("button_down", self, "post_pressed")
	load_comments()
	
func anim_in():
	anim.play("in")
	
func back_pressed():
	anim.play("out")

func post_pressed():
	if get_parent().selected_level != "" || UserInfo.token != "":
		var dic = {"level" : get_parent().selected_level, "author": UserInfo.id, "content": textedit.text}
		var body = JSON.print(dic)
		var headers = ["Authorization: Bearer " + UserInfo.token, "Content-Type: application/json", "Accept: application/json"]
		httpreq2.connect("request_completed", self, "on_req2_complete")
		var result = httpreq2.request("https://levelsharesquare.com/api/levels/" + get_parent().selected_level + "/comment", headers, true, 2, body)
	else:
		pass
	
func load_comments(level_id : String ="651f32fcb239ad06ffcb9af2"):
	author_info.clear()
	level_comment_info.clear()
	httpreq1.connect("request_completed", self, "on_req1_complete")
	httpreq1.request("https://levelsharesquare.com/api/levels/" + level_id + "/comments?page=1")

func on_req2_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(response_code)
	print(json.result)
	load_comments(get_parent().selected_level)
	textedit.text = ""

func on_req1_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result["total"] != 0:
		label.text = ""
		label.modulate.a = 1
		var comments = json.result["levelComments"]
		for i in json.result["levelComments"].size():
			label.text += comments[i]["author"]["username"] + ": \n" + comments[i]["content"] + "\n\n"
	
	else:
		label.text = "No comments found. Be the first!"
		label.modulate.a = 0.5
