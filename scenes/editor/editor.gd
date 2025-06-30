class_name Editor
extends LevelDataLoader


const mode: int = 1
const TILE_SIZE := Vector2(32, 32)


export(NodePath) var shared_path

var placed_item_property = null

var mouse_position := Vector2.ZERO
var mouse_tile_position := Vector2.ZERO

var last_mouse_pos := Vector2.ZERO
var last_mouse_tile_pos := Vector2.ZERO

var left_held: bool = false
var right_held: bool = false

# Just useless debug stuff don't mind this
#var temp

onready var current_tool = $Tools/Pen

onready var tools_container = $Tools


func _ready():
	#this is to dynamically update the framerate
	_update_editor_framerate()
	
#	temp = Control.new()
#	add_child(temp)
	
	Engine.iterations_per_second = 60
	# reset these to 0 since they get incremented by the loading in process every time
	Singleton.CurrentLevelData.next_shine_id = 0
	Singleton.CurrentLevelData.next_star_coin_id = 0
	Singleton.CheckpointSaved.reset()
	
	var data = Singleton.CurrentLevelData.level_data
	load_in(data, data.areas[Singleton.CurrentLevelData.area])
	
	# if the mode switch button is invisible then the editor hasn't been readyed for the first time yet
	# (editor _ready() gets called every time a mode switch happens)
	# if the button is invisible and we're in the editor scene, we know it's time to setup the editor for the first time
	if Singleton.ModeSwitcher.button.invisible:
		# enable the mode switching button since we're using the editor
		Singleton.ModeSwitcher.button.change_button_state(true)
		Singleton.Music.play() # needed as the music no longer plays by default
	
		# make sure the mode switcher button is set to have the play button as it's visual
		Singleton.ModeSwitcher.button.change_visuals(0)
	
		Singleton.CurrentLevelData.unsaved_editor_changes = false


func _unhandled_input(event):
	if Input.is_action_pressed("place"):
		left_held = true
	else:
		left_held = false
		
	if Input.is_action_pressed("erase"):
		right_held = true
	else:
		right_held = false
	
	print("left: ", left_held)
	print("right: ", right_held)


func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	mouse_tile_position = (mouse_position / 32).floor()
	
	if is_instance_valid(current_tool):
		current_tool._update(delta)
	
	last_mouse_pos = mouse_position
	last_mouse_tile_pos = mouse_tile_position


func _update_editor_framerate():
	fps_util._update_framerate(true)
	get_tree().create_timer(1.0).connect("timeout", self, "_update_editor_framerate")


func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")


func get_shared_node() -> LevelShared:
	return get_node(shared_path) as LevelShared
