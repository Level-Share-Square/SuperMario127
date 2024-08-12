extends Panel


onready var button_left = $NumControl/ButtonLeft
onready var button_right = $NumControl/ButtonRight
onready var button_rate = $NumControl/ButtonRate
onready var login_popup = $LoginPopup
onready var rate_value_label = $NumControl/Label
onready var httpreq = $HTTPRequest

var rate_value : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	button_left.connect("button_down", self, "on_left_pressed")
	button_right.connect("button_down", self, "on_right_pressed")
	button_rate.connect("button_down", self, "on_rate_pressed")
	
func _process(delta):
	rate_value_label.text = str(rate_value)
	if UserInfo.username != "":
		login_popup.visible = false
	else:
		login_popup.visible = true
	
func on_left_pressed():
	if rate_value <= 1:
		return
	else:
		rate_value -= 0.5
		
func on_right_pressed():
	if rate_value >= 5:
		return
	else:
		rate_value += 0.5
		
func on_rate_pressed():
	var dic = {"starRate": rate_value}
	var body = JSON.print(dic)
	var headers = ["Authorization: Bearer " + UserInfo.token, "Content-Type: application/json", "Accept: application/json"]
	httpreq.connect("request_completed", self, "on_req1_complete")
	var result = httpreq.request("https://levelsharesquare.com/api/levels/" + get_parent().get_parent().selected_level + "/rate", headers, true, 8, body)
	print(get_parent().get_parent().selected_level)

func on_req1_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(response_code)
	print(json.result)
	if response_code == 200:
		$AnimationPlayer.play("rated")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
