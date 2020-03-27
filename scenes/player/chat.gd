extends VBoxContainer

onready var text_enter = $EnterText
onready var text_label = $RichTextLabel

var colors = [
	"red",
	"green"
]

func _ready():
	text_enter.connect("text_entered", self, "text_entered")
	get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")

func add_message(text, player_id):
	text_label.bbcode_text += "\n"
	text_label.bbcode_text += "[color=" + colors[player_id] + "]"
	text_label.bbcode_text += "Player " + str(player_id + 1) + "[/color]: "
	text_label.bbcode_text += text
	
func text_entered(text):
	text_enter.release_focus()
	if text != "":
		print_debug("A")
		add_message(text, PlayerSettings.my_player_index)
		text_enter.text = ""
		get_tree().multiplayer.send_bytes(JSON.print(["send message", text]).to_ascii())

func _process(delta):
	if PlayerSettings.other_player_id != -1:
		visible = true
	else:
		visible = false
	FocusCheck.is_ui_focused = text_enter.has_focus()
		
func _input(event):
	if event.is_action_pressed("cancel_chat"):
		text_enter.release_focus()

func _packet_recieved(id, packet_ascii):
	var packet = JSON.parse(packet_ascii.get_string_from_ascii()).result
	if packet[0] == "send message":
		add_message(packet[1], 1 if PlayerSettings.my_player_index == 0 else 0)
