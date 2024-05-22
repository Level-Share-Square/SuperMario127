extends Control

# Leave for other programmer (that isn't Charlotte ) - Detect if this is the options menu in the title screen or in game, if the former, make page switching inaccessable

onready var page_1 = $Page1
onready var page_2 = $Page2

onready var volume_mixer = $VolumeMixer
onready var volume_mixer_exit = $VolumeMixer/MixerSettings/CloseButton

onready var controls_button = $Page1/ControlsButton
onready var title_only = $TitleOnly


onready var page_select = $PageSelect
onready var page_select_right = $PageSelect/Right
onready var page_select_left = $PageSelect/Left
onready var page_select_value = $PageSelect/Value

var vm_exit_last_hovered
var vm_open = false
var page = 1

func _ready():
	page = 1
	volume_mixer.visible = false
	page_select_value.text = "1"
	title_only.queue_free()
	controls_button.controls_options = get_parent().get_node("ControlsOptions")

func _on_Right_pressed():
	if page_select_value.text == "1":
		page = 2
		page_select_value.text = "2"

	elif page_select_value.text == "2":
		page = 1
		page_select_value.text = "1"


func _on_Left_pressed():
	if page_select_value.text == "1":
		page = 2
		page_select_value.text = "2"

	elif page_select_value.text == "2":
		page = 1
		page_select_value.text = "1"

func _process(delta):
	if page == 1 && vm_open == false:
		page_2.visible = false
		page_1.visible = true
	elif page == 2 && vm_open == false:
		page_2.visible = true
		page_1.visible = false
	else:
		vm_open = true
		volume_mixer.visible = true
		page_2.visible = false
		page_1.visible = false

	if vm_open:
		page_select.visible = false
	else:
		page_select.visible = true

	if volume_mixer_exit.is_hovered() and !vm_exit_last_hovered:
		$VolumeMixer/MixerSettings/CloseButton/HoverSound.play()
	vm_exit_last_hovered = volume_mixer_exit.is_hovered()


func _on_CloseButton_pressed():
	$VolumeMixer/MixerSettings/CloseButton/ClickSound.play()
	$VolumeMixer.visible = false
	vm_open = false
	page_select.visible = true
