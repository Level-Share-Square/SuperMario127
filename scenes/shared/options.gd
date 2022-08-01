extends Control

onready var page_1 = $Page1
onready var page_2 = $Page2

onready var controls_button = $Page1/ControlsButton
onready var title_only = $TitleOnly

onready var page_select_right = $PageSelect/Right
onready var page_select_left = $PageSelect/Left
onready var page_select_value = $PageSelect/Value

var page = 1

func _ready():
	page_select_value.text = "1/2"
	title_only.queue_free()
	controls_button.controls_options = get_parent().get_node("ControlsOptions")
	print(page_select_value)

func _on_Right_pressed():
	if page_select_value.text == "1/2":
		page = 2
		page_select_value.text = "2/2"

	elif page_select_value.text == "2/2":
		page = 1
		page_select_value.text = "1/2"

	else:
		page = "WHAT"
		page_select_value.text = "nill"


func _on_Left_pressed():
	if page_select_value.text == "1/2":
		page = 2
		page_select_value.text = "2/2"

	elif page_select_value.text == "2/2":
		page = 1
		page_select_value.text = "1/2"

	else:
		page = "WHAT"
		page_select_value.text = "nill"

func _process(delta):
	if page == 1:
		page_2.visible = false
		page_1.visible = true
	elif page == 2:
		page_2.visible = true
		page_1.visible = false






