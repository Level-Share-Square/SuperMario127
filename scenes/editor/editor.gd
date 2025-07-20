class_name Editor
extends LevelDataLoader


const mode: int = 1
const TILE_SIZE := Vector2(32, 32)
export var placeable_items: Resource


export(NodePath) var shared_path

var placed_item_property = null

var hovered_objects: Dictionary = {}
var selected_objects: Dictionary = {}
var selected_item: PlaceableItem

onready var editor_camera: Camera2D = $"%EditorCamera"
onready var tool_manager: ToolManager = $"%Tools"
onready var tile_buffer: TileMap = $"%TileBuffer"
onready var action_manager: ActionManager = $"%ActionManager"

onready var save_button = $UI/EditorUI/Utilities/Save
onready var editor_options = $UI/EditorOptionsWindow
onready var selection_box = $"%ObjectSelection".get_node("SelectionBox")
onready var edit_selection = $"%EditSelection"


onready var backgrounds = $Backgrounds


signal item_changed(placeable_item)


func _ready():
	selected_item = placeable_items.placeable_items["til_grass"]
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


func on_save_pressed():

	Singleton.CurrentLevelData.level_info.level_name = editor_options.level_name.text
	Singleton.CurrentLevelData.level_info.level_author = editor_options.author.text
	Singleton.CurrentLevelData.level_info.level_description = editor_options.description.text
	Singleton.CurrentLevelData.level_info.thumbnail_url = editor_options.thumbnail_url.text
	
	var level_id: String = Singleton.CurrentLevelData.level_id
	var working_folder: String = Singleton.CurrentLevelData.working_folder
	var level_code: String = Singleton.CurrentLevelData.level_data.get_encoded_level_data()
	
	var file_path = level_list_util.get_level_file_path(level_id, working_folder)
	level_list_util.save_level_code_file(level_code, file_path)
	
	for save_slot in range(4):
		var save_path = level_list_util.get_level_save_path(
			level_id, working_folder, save_slot - 1
		)
		if level_list_util.file_exists(save_path):
			level_list_util.delete_file(save_path)
			
	Singleton.CurrentLevelData.level_info.reset_save_data(false)
	Singleton.CurrentLevelData.level_info.init_collectibles()
	save_meta_util.update_all_with_level(level_id, working_folder, false, Singleton.CurrentLevelData.level_info)
	
	Singleton.CurrentLevelData.unsaved_editor_changes = false


func object_hovered(object: GameObject):
	print(object.position)
	if tool_manager.current_tool.tool_type == EditorTool.Type.TileTool:
		return
	
	# Look you come up with a better object ID system when you have none
	hovered_objects.get_or_add(object.name, object)
	object.hovered = true
	object.modulate.a = 0.5


func object_unhovered(object: GameObject):
	if not object in hovered_objects.values():
		return
	
	hovered_objects.erase(object.name)
	object.hovered = false
	object.modulate.a = 1


func _process(delta):
	if Input.is_action_just_pressed("middle"):
		selection_box.show()
		selection_box.get_parent().show()
	for i in selected_objects:
		i.modulate = Color(0.7, 0.7, 1.2, i.modulate.a)


#func object_clicked(object: GameObject):
#	if tool_manager.current_tool.tool_type == EditorTool.Type.TileTool:
#		return
#
#	object.selected = !object.selected
#	if object.selected:
#		selected_objects.get_or_add(object, object.name)
#		object.modulate = Color(0.7, 0.7, 1.2, object.modulate.a)
#	else:
#		selected_objects.erase(object)
#		object.modulate = Color(1, 1, 1, object.modulate.a)
	


func _update_editor_framerate():
	fps_util._update_framerate(true)
	get_tree().create_timer(1.0).connect("timeout", self, "_update_editor_framerate")


func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")


func get_shared_node() -> LevelShared:
	return get_node(shared_path) as LevelShared
	
func new_item_selected(placeable_item):
	selected_item = placeable_item
	emit_signal("item_changed", placeable_item)
