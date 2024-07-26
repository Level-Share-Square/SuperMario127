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

onready var scroll = $ScrollContainer
onready var panel = $PanelContainer2
onready var panel1 = $PanelContainer
onready var levellist = $LevelListPanel

onready var openc = $OpenC
onready var opend = $OpenD

var opened_tab
var opened = false

const COMMENT_TAB = "Comments"
const DESCRIPTION_TAB = "Desc"

var comment_dict : Dictionary

func _process(delta):
	$PanelContainer2/buttonX.margin_left = 220
	
	if opened_tab == COMMENT_TAB:
		post.show()
		$PanelContainer2.show()
		$ScrollContainer.show()
		$RichTextLabel.hide()
		$LevelListPanel.rect_size = Vector2(266, 366)
		$PanelContainer.rect_size = Vector2(251, 349)
		$LevelListPanel.rect_position = Vector2(502, 70)
		$PanelContainer.rect_position = Vector2(509, 79)
	elif opened_tab == DESCRIPTION_TAB:
		post.hide()
		$PanelContainer2.hide()
		$ScrollContainer.hide()
		$RichTextLabel.show()
		$LevelListPanel.rect_size = Vector2(266, 428)
		$PanelContainer.rect_size = Vector2(251, 415)
		$LevelListPanel.rect_position = Vector2(502, 5)
		$PanelContainer.rect_position = Vector2(509, 13)

# Called when the node enters the scene tree for the first time.
func _ready():
	opened_tab = COMMENT_TAB
	textedit.connect("button_down", self, "on_edit")
	back.connect("button_down", self, "back_pressed")
	post.connect("button_down", self, "post_pressed")
	openc.connect("button_down", self, "comment_button")
	opend.connect("button_down", self, "desc_button")
	load_comments()
	
func comment_button():
	opened_tab = COMMENT_TAB
	anim_in()
	
func desc_button():
	opened_tab = DESCRIPTION_TAB
	anim_in()

func load_description(text):
	$RichTextLabel.text = text
	
func anim_in():
	if opened == false:
		anim.play("in")
		opened = true
	
func back_pressed():
	anim.play("out")
	opened = false

func on_edit():
	var window = preload("res://scenes/editor/window/TextInput2.tscn")
	var window_child = window.instance()
	Singleton2.disable_hotkeys = true
	add_child(window_child)
	window_child.set_as_toplevel(true)
	window_child.get_node("Contents/TextEdit").text = textedit.text
	window_child.get_node("Contents/CancelButton").string = self
	window_child.get_node("Contents/SaveButton").string = self

func post_pressed():
	if textedit.text != "Comment" or textedit.text != "":
		if get_parent().selected_level != "" || UserInfo.token != "":
			var dic = {"level" : get_parent().selected_level, "author": UserInfo.id, "content": textedit.text}
			var body = JSON.print(dic)
			var headers = ["Authorization: Bearer " + UserInfo.token, "Content-Type: application/json", "Accept: application/json"]
			httpreq2.connect("request_completed", self, "on_req2_complete")
			var result = httpreq2.request("https://levelsharesquare.com/api/levels/" + get_parent().get_parent().selected_level + "/comment", headers, true, 2, body)
		else:
			pass
	
func load_comments(level_id : String ="651f32fcb239ad06ffcb9af2"):
	if comment_dict.has(level_id):
		label.text = comment_dict[level_id]
	else:
		author_info.clear()
		level_comment_info.clear()
		httpreq1.connect("request_completed", self, "on_req1_complete")
		httpreq1.request("https://levelsharesquare.com/api/levels/" + level_id + "/comments?page=1")

func on_req2_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(response_code)
	print(json.result)
	author_info.clear()
	level_comment_info.clear()
	httpreq1.connect("request_completed", self, "on_req1_complete")
	httpreq1.request("https://levelsharesquare.com/api/levels/" + get_parent().get_parent().selected_level + "/comments?page=1")
	textedit.text = "Comment"

func on_req1_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result == null:
		label.text = "An error occured. Please try again later!"
		label.modulate.a = 0.5
		return
	if json.result["total"] != 0:
		label.text = ""
		label.modulate.a = 1
		var comments = json.result["levelComments"]
		for i in json.result["levelComments"].size():
			label.text += comments[i]["author"]["username"] + ": \n" + comments[i]["content"] + "\n\n"
			comment_dict[get_parent().get_parent().selected_level] = label.text
	
	else:
		label.text = "No comments found. Be the first!"
		label.modulate.a = 0.5
