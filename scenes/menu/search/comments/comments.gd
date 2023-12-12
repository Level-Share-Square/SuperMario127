extends Control

var author_info : Dictionary = {}
var level_comment_info = {}

onready var anim = $AnimationPlayer
onready var httpreq1 = $HTTPRequest
onready var back = $"127BackButton"
onready var label = $ScrollContainer/Label

func _process(delta):
	$PanelContainer2/buttonX.margin_left = 220

# Called when the node enters the scene tree for the first time.
func _ready():
	back.connect("button_down", self, "back_pressed")
	load_comments()
	
func anim_in():
	anim.play("in")
	
func back_pressed():
	anim.play("out")
	
func load_comments(level_id : String ="651f32fcb239ad06ffcb9af2"):
	author_info.clear()
	level_comment_info.clear()
	httpreq1.connect("request_completed", self, "on_req1_complete")
	httpreq1.request("https://levelsharesquare.com/api/levels/" + level_id + "/comments?page=1")

func on_req1_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result["authors"] != null:
		label.text = ""
		label.modulate.a = 1
		for i in json.result["authors"].size():
			author_info[json.result["authors"][i]["_id"]] = [json.result["authors"][i]["username"], json.result["authors"][i]["avatar"]]
		for i in json.result["levelComments"].size():
			print(author_info.keys()[i])
			level_comment_info[json.result["levelComments"][i]["author"]] = json.result["levelComments"][i]["content"]
			print(level_comment_info.keys()[i])
			
		for i in json.result["levelComments"].size():
			label.text += author_info[author_info.keys()[i]][0] + ":\n" + level_comment_info[author_info.keys()[i]] + "\n\n"
	else:
		label.text = "No comments found. Be the first!"
		label.modulate.a = 0.5
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
