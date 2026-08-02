extends HBoxContainer

onready var quit = $Quit
onready var quit_icon = $Quit
onready var quit_countdown = $Quit/Countdown

onready var options = $Options
onready var options_icon = $Options/Icon

func _ready():
	quit.disabled = Singleton.ModeSwitcher.visible
	quit_countdown.countdown_style = quit_countdown.TextStyle.right
