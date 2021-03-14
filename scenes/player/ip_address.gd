extends LineEdit

func _ready():
	text = Singleton.PlayerSettings.connect_to_ip
	var _connect = connect("focus_exited", self, "update_ip")
	
func update_ip():
	Singleton.PlayerSettings.connect_to_ip = text

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()
