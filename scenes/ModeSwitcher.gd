extends Node2D

onready var global_vars_node = get_node("../GlobalVars")
onready var character = get_node("../Character")
onready var ghost_tile = get_node("../GhostTile")
onready var grid = get_node("../Grid/ParallaxLayer")
onready var banner = get_node("../UI/Banner")
onready var music = get_node("../Music")

func switch_modes():
	if global_vars_node.game_mode == "Testing":
		switch_to_editing()
	else:
		switch_to_testing()
	
func switch_to_editing():
	global_vars_node.game_mode = "Editing"
	global_vars_node.unload()
	character.hide()
	ghost_tile.show()
	grid.show()
	banner.show()
	music.stop()

func switch_to_testing():
	global_vars_node.game_mode = "Testing"
	global_vars_node.reload()
	character.show()
	ghost_tile.hide()
	grid.hide()
	banner.hide()
	music.play()
	
	if Input.is_key_pressed(KEY_SHIFT):
		character.position = get_global_mouse_position()

func _ready():
	if global_vars_node.game_mode == "Editing":
		switch_to_editing()
	else:
		switch_to_testing()

func _process(delta):
	if Input.is_action_just_pressed("switch_modes"):
		switch_modes()
