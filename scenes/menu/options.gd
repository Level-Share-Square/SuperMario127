extends Screen

onready var page_1 = $Page1
onready var page_2 = $Page2

onready var controls_button = $Page1/ControlsButton
onready var back_button = $TitleOnly/Bottom/BackButton
onready var page_select_right = $PageSelect/Right
onready var page_select_left = $PageSelect/Left
onready var page_select_value = $PageSelect/Value

var page = 1

func _ready():
	var _connect = back_button.connect("pressed", self, "go_back")
	_connect = controls_button.connect("pressed", self, "open_controls")

func go_back():
	emit_signal("screen_change", "options_screen", "main_menu_screen")

func open_controls():
	emit_signal("screen_change", "options_screen", "controls_screen")
	
func _on_Right_pressed():
	if page == 1:
		page = 2
		page_select_value.text = "2/2"

	elif page == 2:
		page = 1
		page_select_value.text = "1/2"

	else:
		page = 1
		page_select_value.text = "1/2"


func _on_Left_pressed():
	if page == 1:
		page = 2
		page_select_value.text = "2/2"

	elif page == 2:
		page = 1
		page_select_value.text = "1/2"

	else:
		page = 1
		page_select_value.text = "1/2"

func _process(delta):
	if page == 1:
		page_2.visible = false
		page_1.visible = true
	elif page == 2:
		page_2.visible = true
		page_1.visible = false

