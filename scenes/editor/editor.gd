class_name Editor
extends LevelDataLoader


const mode: int = 1
const TILE_SIZE := Vector2(32, 32)
export var placeable_items: Resource


export(NodePath) var shared_path

var placed_item_property = null

var hovered_objects: Dictionary = {}
var selected_item: PlaceableItem

var mouse_position := Vector2.ZERO
var last_mouse_pos := Vector2.ZERO

var left_held: bool = false
var right_held: bool = false

# Just useless debug stuff don't mind this
#var temp

onready var current_tool = $Tools/Pen

onready var tools_container = $Tools


func _ready():
	selected_item = placeable_items.placeable_items["coin"]
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
	left_held = Input.is_action_pressed("place")
	right_held = Input.is_action_pressed("erase")


func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	
	if is_instance_valid(current_tool):
		current_tool._update(delta)
	
	last_mouse_pos = mouse_position


func object_hovered(object: GameObject):
	# Look you come up with a better object ID system when you have none
	hovered_objects.get_or_add(object.name, object)
	object.hovered = true
	object.modulate.a = .5
	print(hovered_objects)


func object_unhovered(object: GameObject):
	hovered_objects.erase(object.name)
	object.hovered = false
	object.modulate.a = 1
	print(hovered_objects)


func _update_editor_framerate():
	fps_util._update_framerate(true)
	get_tree().create_timer(1.0).connect("timeout", self, "_update_editor_framerate")


func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")


func get_shared_node() -> LevelShared:
	return get_node(shared_path) as LevelShared
	
func new_item_selected(placeable_item):
	selected_item = placeable_item
