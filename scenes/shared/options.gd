extends Control

onready var controls_button = $ControlsButton
onready var title_only = $TitleOnly

func _ready():
	title_only.queue_free()
	controls_button.controls_options = get_parent().get_node("ControlsOptions")
