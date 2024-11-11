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

var mod_active: bool = false
var mod_path: String

var editor_hotkeys = [
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
	"invis_ui",
]

var player_hotkeys = [
	"pause",
	"mute",
	"toggle_show",
	"reload",
	"reload_from_start",
	"toggle_crt",
	"fullscreen",
	"volume_up",
	"volume_down",
	"1",
]

var default_hotkeys = editor_hotkeys + player_hotkeys
signal dark_mode_toggled

func toggle_dark_mode():
	emit_signal("dark_mode_toggled")

func _init():
	var file = File.new()
	file.open("user://mods/active.127mod", file.READ)
	mod_path = file.get_line()
	var success = ProjectSettings.load_resource_pack(mod_path)
	print(success)
	mod_active = success

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

func _process(delta):
	if save_ghost == true:
		yield(get_tree().create_timer(0.5), "timeout")
		save_ghost = false
