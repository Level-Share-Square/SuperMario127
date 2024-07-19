extends VBoxContainer

onready var text_enter = $EnterText
onready var text_label = $RichTextLabel

var colors = [
	"red",
	"green"
]

func _ready():
	var _connect = text_enter.connect("focus_entered", self, "_focused")
	var _connect2 = text_enter.connect("focus_exited", self, "_unfocused")
	var _connect3 = text_enter.connect("text_entered", self, "text_entered")
	var _connect4 = get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")

func add_message(text, player_id, username = ""):
	text_label.bbcode_text += "\n"
	text_label.bbcode_text += "[color=" + colors[player_id] + "]"
	if username == "":
		text_label.bbcode_text += "Player " + str(player_id + 1) + "[/color]: "
	else:
		text_label.bbcode_text += username + "[/color]: "
	text_label.bbcode_text += text
	
func text_entered(text):
	text_enter.release_focus()
	if text != "":
		if UserInfo.username == "":
			add_message(text, Singleton.PlayerSettings.my_player_index)
		else:
			add_message(text, Singleton.PlayerSettings.my_player_index, UserInfo.username)
		text_enter.text = ""
		if UserInfo.username == "":
			var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["send message", text]).to_ascii())
		else:
			var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["send message", text, UserInfo.username]).to_ascii())

func _process(_delta):
	visible = false
	
func _focused():
	Singleton.FocusCheck.is_ui_focused = true

func _unfocused():
	Singleton.FocusCheck.is_ui_focused = false
		
func _input(event):
	if event.is_action_pressed("cancel_chat"):
		text_enter.release_focus()

func _packet_recieved(_id, packet_ascii):
	var packet = JSON.parse(packet_ascii.get_string_from_ascii()).result
	if packet[0] == "send message":
		if UserInfo.username == "":
			add_message(packet[1], 1 if Singleton.PlayerSettings.my_player_index == 0 else 0)
		else:
			add_message(packet[1], 1 if Singleton.PlayerSettings.my_player_index == 0 else 0, packet[2])
