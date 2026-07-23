class_name Editor
extends LevelDataLoader

const mode: int = 1
const TILE_SIZE := Vector2(32, 32)
export var placeable_items: Resource


export(NodePath) var shared_path

var placed_item_property = null
var pixel_lock = true
var object_layering = true
var show_layers = false

var layer: int = 0

var hovered_objects: Dictionary = {}
var selected_objects: Dictionary = {}
var selected_tiles: Dictionary = {}
var selected_item: PlaceableItem

onready var editor_camera: Camera2D = $"%EditorCamera"
onready var tool_manager: ToolManager = $"%Tools"
onready var tile_buffer: TileMap = $"%TileBuffer"
onready var object_buffer = $"%ObjectBuffer"
onready var action_manager: ActionManager = $"%ActionManager"
onready var item_actions = $"%ItemActions"
onready var screen_manager = $"%ScreenManager"
onready var save_manager = $"SaveManager"

onready var save_button = $UI/EditorUI/Utilities/Save
onready var level_settings = $"%LevelSettingsWindow"
onready var edit_selection = $"%EditSelection"
onready var item_preview = $"%ItemPreview"


onready var backgrounds = $Backgrounds


signal item_changed(placeable_item)


func _ready():
	item_preview.update_item(selected_item, selected_item.palette, true)
	#this is to dynamically update the framerate
	_update_editor_framerate()
	
#	temp = Control.new()
#	add_child(temp)
	
	Engine.iterations_per_second = 60
	# reset these to 0 since they get incremented by the loading in process every time
	CurrentLevelData.next_shine_id = 0
	CurrentLevelData.next_star_coin_id = 0
	Singleton.CheckpointSaved.reset()
	
	load_in()
	
	
	# if the mode switch button is invisible then the editor hasn't been readyed for the first time yet
	# (editor _ready() gets called every time a mode switch happens)
	# if the button is invisible and we're in the editor scene, we know it's time to setup the editor for the first time
	if Singleton.ModeSwitcher.button.invisible:
		# enable the mode switching button since we're using the editor
		Singleton.ModeSwitcher.button.change_button_state(true)
		Singleton.Music.play() # needed as the music no longer plays by default
	
		# make sure the mode switcher button is set to have the play button as it's visual
		Singleton.ModeSwitcher.button.change_visuals(0)
	
		CurrentLevelData.unsaved_editor_changes = false
		
	item_actions.verify_clipboard()


func object_hovered(object):
	if tool_manager.current_tool.tool_type == EditorTool.Type.TileTool:
		return
	if get_shared_node().layers.find(object.level_layer_ref.get_ref()) != layer:
		return
	
	# Look you come up with a better object ID system when you have none
	hovered_objects.get_or_add(object.name, object)
	object.hovered = true
	object.modulate_set()


func object_unhovered(object):
	if not object in hovered_objects.values():
		return
	
	hovered_objects.erase(object.name)
	object.hovered = false
	object.modulate_set()
		


func _update_editor_framerate():
	fps_util._update_framerate(true)
	get_tree().create_timer(1.0).connect("timeout", self, "_update_editor_framerate")


func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")


func get_shared_node() -> LevelShared:
	return get_node(shared_path) as LevelShared
	
