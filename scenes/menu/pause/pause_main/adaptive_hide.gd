extends HBoxContainer

onready var shine_map = $ShineMap

onready var quit = $Quit
onready var quit_icon = $Quit
onready var quit_countdown = $Quit/Countdown

onready var options = $Options
onready var options_icon = $Options/Icon

func _ready():
	quit.disabled = Singleton.ModeSwitcher.get_node("ModeSwitcherButton").visible
	
	if !shine_map.visible:
		quit_countdown.countdown_style = quit_countdown.TextStyle.right
	else:
		quit_icon.visible = false
		options_icon.visible = false
		
		options.text = options.text.dedent()
