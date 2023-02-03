extends Node2D

var rp : bool = true
var dead = false
var player_name
var current_var
var save_ghost = false
var level
var ghost_enabled = true
var crash
var crash_happened = "no"

func _ready():
	yield(get_tree().create_timer(3),"timeout")
	if crash == true:
		crash_happened = "yes"
	if crash == false:
		crash_happened = "no"
		crash = true
		
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		crash = false
	
func _process(delta):
	print(crash)
	print(crash_happened)
