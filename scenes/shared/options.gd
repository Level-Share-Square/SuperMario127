extends Control

onready var controls_button = $ControlsButton
onready var title_only = $TitleOnly

onready var page_select_right = $PageSelect/Right
onready var page_select_left = $PageSelect/Left
onready var page_select_value = $PageSelect/Value.text

func _ready():
	page_select_value = "1/2"
	title_only.queue_free()
	controls_button.controls_options = get_parent().get_node("ControlsOptions")
	print(page_select_value)

func _on_Right_pressed():
	if page_select_value == "1/2":
		page_select_value = "2/2"
