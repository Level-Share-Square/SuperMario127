extends Node2D

onready var global_vars_node = get_node("../GlobalVars")
onready var character = get_node("../Character")
onready var ghost_tile = get_node("../GhostTile")
onready var grid = get_node("../Grid/ParallaxLayer")
onready var tile_map = get_node("../TileMap")
onready var banner = get_node("../UI/Banner")
onready var test_button = get_node("../UI/Banner/Testing")
onready var stop_button = get_node("../UI/StopButton")
onready var music = get_node("../Music")
onready var ghost_tile_container = get_node("../GhostTileContainer")

func switch_modes():
	if global_vars_node.game_mode == "Testing":
		switch_to_editing()
	else:
		switch_to_testing()
	
func switch_to_editing():
	stop_button.disabled = true
	test_button.disabled = false
	yield(VisualServer, 'frame_post_draw')
	global_vars_node.game_mode = "Editing"
	global_vars_node.unload()
	global_vars_node.editor.load_in(self)
	character.hide()
	stop_button.hide()
	ghost_tile.show()
	grid.show()
	banner.show()
	music.stop()
	ghost_tile_container.visible = true

func switch_to_testing():
	stop_button.disabled = false
	test_button.disabled = true
	yield(VisualServer, 'frame_post_draw')
	global_vars_node.game_mode = "Testing"
	global_vars_node.editor.unload(self)
	global_vars_node.reload()
	character.controllable = true
	character.show()
	character.set_state_by_name("Fall", 0)
	stop_button.show()
	ghost_tile.hide()
	grid.hide()
	banner.hide()
	music.play()
	ghost_tile_container.visible = false
	
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
	if Input.is_action_just_pressed("copy_level") and global_vars_node.game_mode == "Editing":
		global_vars_node.editor.save_out(self)
	if Input.is_action_just_pressed("paste_level") and global_vars_node.game_mode == "Editing":
		var editor = global_vars_node.editor
		editor.unload(self)
		var level = Level.new()
		var level_json = LevelJSON.new()
		if OS.has_feature('JavaScript'):
			var js_return = JavaScript.eval("""navigator.permissions.query({name: 'clipboard-read'}).then(result => { if (result.state == 'granted' || result.state == 'prompt') {return navigator.clipboard.readText();}})""", true);
			level_json.contents = js_return
			print("a")
		else:
			level_json.contents = OS.clipboard
		level.load_in(level_json)
		global_vars_node.level = level
		global_vars_node.area = level.areas[0]
		editor.area = level.areas[0]
		editor.load_in(self)
		pass
