extends Control

export var default_screen: NodePath
onready var current_screen: Control = get_node(default_screen)

func _ready():
	for screen in get_children():
		screen.connect("screen_change", self, "screen_change")

func screen_change(new_screen_name: String):
	var new_screen = get_node(new_screen_name)
	
	current_screen.visible = false
	current_screen = new_screen
	
	new_screen.animation_player.play_backwards("transition")
	new_screen.visible = true
