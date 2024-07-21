extends Node

var temp_ga
var temp_gp
var temp_gsr
var temp_gar

var ghost_pos
var ghost_anim
var ghost_area_array
var ghost_rotation
var reload = null

var dont_save = false

var frame_counter = -1

func _process(delta):
	if "MainMenuController" in str(get_tree().current_scene):
		dont_save = false
		temp_ga = []
		temp_gp = []
		temp_gsr = []
		temp_gar = []
		ghost_pos = []
		ghost_anim = []
		ghost_rotation = []
		ghost_area_array = []
		frame_counter = -1
		
	if reload == OK:
		reset()
		reload = null
		
	if Input.is_action_just_pressed("reload_from_start"):
		dont_save = false
		yield(get_tree().create_timer(0.1), "timeout")
		reset()
		
func reset():
		temp_ga = []
		temp_gp = []
		temp_gsr = []
		temp_gar = []
		frame_counter = -1
