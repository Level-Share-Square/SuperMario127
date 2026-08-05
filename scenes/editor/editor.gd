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

var layer: String = ""

var hovered_objects: Dictionary = {}
var selected_objects: Array = []
var selected_tiles: Dictionary = {}
var selected_item: PlaceableItem

onready var parallax_scroll = $"%ParallaxScroll"
onready var editor_camera: Camera2D = $"%EditorCamera"
onready var tool_manager: ToolManager = $"%Tools"
onready var tile_buffer: TileMap = $"%TileBuffer"
onready var object_buffer = $"%ObjectBuffer"
onready var action_manager: ActionManager = $"%ActionManager"
onready var item_actions = $"%Actions"
onready var screen_manager = $"%ScreenManager"
onready var save_manager = $"SaveManager"
onready var object_settings_window = $"%ObjectSettingsWindow"
onready var ui = $"%UI"

onready var save_button = $UI/EditorUI/Utilities/Save
onready var level_settings = $"%LevelSettingsWindow"
onready var edit_selection = $"%EditSelection"
onready var item_preview = $"%ItemPreview"


onready var backgrounds = $Backgrounds


signal item_changed(placeable_item)


func _ready():
	#this is to dynamically update the framerate
	_update_editor_framerate()
	
#	temp = Control.new()
#	add_child(temp)
	
	Engine.iterations_per_second = 60
	# reset these to 0 since they get incremented by the loading in process every time
	CurrentLevelData.next_shine_id = 0
	CurrentLevelData.next_star_coin_id = 0
	CurrentLevelData.checkpoint_data.reset()
	
	load_in()
	
	
	# if the mode switch button is invisible then the editor hasn't been readyed for the first time yet
	# (editor _ready() gets called every time a mode switch happens)
	# if the button is invisible and we're in the editor scene, we know it's time to setup the editor for the first time
	if not Singleton.ModeSwitcher.visible:
		# enable the mode switching button since we're using the editor
		Singleton.ModeSwitcher.visible = true
		Singleton.ModeSwitcher.is_switching = false
		Singleton.Music.play() # needed as the music no longer plays by default
	
		CurrentLevelData.unsaved_editor_changes = false
		
	item_actions.verify_clipboard()
	item_preview.update_item(selected_item, selected_item.palette, selected_item is PlaceableObject)

		

func open_object_properties(selected_objects):
	var objects: Dictionary
	for selected_object in selected_objects:
		objects[selected_object] = selected_object.placeable_item
	object_settings_window.load_objects(objects)


func _update_editor_framerate():
	fps_util._update_framerate(true)
	get_tree().create_timer(1.0).connect("timeout", self, "_update_editor_framerate")


func switch_scenes():
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")


func get_shared_node() -> LevelShared:
	return get_node(shared_path) as LevelShared
	
func get_hovered_objects():
	hovered_objects.clear()
	for object in get_shared_node().get_layer(layer).object_manager.get_children():
		if object.is_object_hovered():
			hovered_objects.get_or_add(object.name, object)

func create_tile_object(cells: Dictionary) -> ObjectData:
#	var viewport := Viewport.new()
#	var tiles := TileMap.new()
#
#	add_child(viewport)
#	viewport.add_child(tiles)
#
#	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
#	viewport.usage = Viewport.USAGE_2D 
#	viewport.transparent_bg = true
#	viewport.render_target_v_flip = true
#
#	tiles.tile_set = load("res://generation/generated_tiles.res")
#	tiles.cell_size = Vector2(32, 32)
#	tiles.cell_custom_transform = Transform2D(Vector2(32, 0), Vector2(0, 32), Vector2.ZERO)
	
	var positions: Array = cells.keys()
	var min_x: int = positions[0].x
	var min_y: int = positions[0].y
	
	for pos in positions:
		if pos.x < min_x: min_x = pos.x
		if pos.y < min_y: min_y = pos.y
	
	var offset := Vector2(min_x, min_y)

	var shifted_cells: Dictionary = {}
	for cell in cells:
#		tiles.set_cellv(cell - offset, tile_util.get_real_tile_set_id(cells[cell][0], cells[cell][1], cells[cell][2]))
#		tiles.update_bitmask_area(cell - offset)
#		tiles.update_bitmask_region()
#		tiles.update_dirty_quadrants()
		shifted_cells[cell - offset] = cells[cell]
	cells = shifted_cells

#	var used_rect: Rect2 = tiles.get_used_rect()
#
#	var tiles_size: Vector2 = used_rect.size * 32
#	viewport.size = tiles_size
#
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#
#	var image := ImageTexture.new()
#	var image_data: Image = viewport.get_texture().get_data()
#
#	var resized_image_data: Image = image_data.duplicate()
#	if image_data != null and !image_data.is_empty():
#		resized_image_data.resize(32, 32, Image.INTERPOLATE_BILINEAR)
#	else:
#		printerr("Error in creating tile object image!")
#
#	image.create_from_image(resized_image_data, 0)

	var tile_data: TileData = LayerData.tiles_to_tile_data(shifted_cells, CurrentLevelData.current_area.layers[get_shared_node().layers.find(layer)].tile_data.chunks)
	var object_data := ObjectData.new(ObjectMetadata.new(offset*32, -1, 0), {4: tile_data})
	
	var action = PlaceObjectAction.new()
	action.shared = get_shared_node()
	action.object_data = object_data
	action.layer = layer
	
	action_manager.commit_action(action)
	
	action = PlaceTilesAction.new()
	action.shared = get_shared_node()
	action.layer = layer
	action.tileset_id = 0
	action.tile_id = 0
	action.palette = 0
	action.do_tiles = selected_tiles.keys()
	action_manager.commit_action(action)
	selected_tiles = {}
	action_manager.commit_action(action)
	get_node("%TileSelection").reset_bounds()
	return object_data



func _on_Button_pressed():
	create_tile_object(selected_tiles)
