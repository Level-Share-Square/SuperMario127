extends Control

signal screen_changed

export var default_screen: NodePath
onready var current_screen: Control = get_node(default_screen)

func _ready():
	if is_instance_valid(current_screen) and current_screen.music_id > -1:
		Singleton.Music.change_song(Singleton.Music.last_song, current_screen.music_id)
	
	for screen in get_children():
		screen.connect("screen_change", self, "screen_change")

func screen_change(new_screen_name: String):
	if is_instance_valid(current_screen):
		current_screen.visible = false
	
	if new_screen_name == "": return
	
	var new_screen = get_node(new_screen_name)
	current_screen = new_screen
	
	new_screen.animation_player.play_backwards("transition")
	new_screen.visible = true
	
	if new_screen.music_id > -1:
		Singleton.Music.change_song(Singleton.Music.last_song, new_screen.music_id)
	
	emit_signal("screen_changed")
