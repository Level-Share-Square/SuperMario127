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
var disable_hotkeys = false
var dark_mode : bool
var autosave_timer : int = 108000
var time : int
var new_box

var default_hotkeys = [
	"toggle_grid",
	"zoom_in",
	"zoom_out",
	"switch_modes",
	"switch_placement_mode",
	"switch_layers",
	"save_level",
	"toggle_transparency",
	"8_pixel_lock",
	"rotate",
	"undo",
	"redo",
	"flip_object",
	"flip_object_v",
	"toggle_enabled",
]

signal dark_mode_toggled

func toggle_dark_mode():
	emit_signal("dark_mode_toggled")

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
	
func reset_time():
	time = autosave_timer

