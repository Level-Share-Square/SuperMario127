extends LevelDataLoader
class_name LevelShared

const GROUND_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/ground_layer/ground_layer.tscn"
const PARALLAX_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/parallax_layer/parallax_layer.tscn"


var ground_layer_scene: PackedScene = preload(GROUND_LAYER_SCENE_PATH)
var parallax_layer_scene: PackedScene = preload(PARALLAX_LAYER_SCENE_PATH)

var layers: Array
var origin: LevelGroundLayer

const layer_index_offset: int = -2
const layer_spacing: int = 16

export var boo_block_texture = "res://assets/tiles/boo_block/boo_block.png"
export var boo_block_texture_invis = "res://assets/tiles/boo_block/boo_block_invis.png"

onready var loaded_boo_texture = load(boo_block_texture)
onready var loaded_boo_texture_invis = load(boo_block_texture_invis)

signal layer_added(layer)
signal found_origin

func load_in():
	load_layers(CurrentLevelData.current_area.layers)
	var tex = loaded_boo_texture
	if get_tree().get_current_scene().mode == 0:
		tex = loaded_boo_texture_invis
	layers[0].tile_map_manager.tile_set.tile_set_texture(18, tex)

func load_layers(layer_data_list: Array):
	for layer_data in layer_data_list:
		layer_data = layer_data
		var layer: LevelLayer = add_layer(layer_data)
		
		if layer.layer_data.layer_metadata.is_origin:
			origin = layer
			emit_signal("found_origin", origin.layer_data.layer_metadata.order)
			
	# This is a failsafe in case none of the layers are origin
	if !origin:
		origin = layers[2]
		emit_signal("found_origin", origin.layer_data.layer_metadata.order)

func get_layer_index(layer: LevelLayer):
	return layers.find(layer)
	
func get_layer_at(index: int):
	return layers[index]

func add_layer(layer_data = null, add_to_data: bool = false, at: int = layers.size()) -> LevelLayer:
	if not is_instance_valid(layer_data):
		var layer_metadata = LayerMetadata.new()
		layer_data = LayerData.new(layer_metadata, TileData.new(), [])
	
	var new_layer: LevelLayer
	if layer_data.layer_metadata.is_ground:
		new_layer = ground_layer_scene.instance()
	else:
		new_layer = parallax_layer_scene.instance()
	
	add_child(new_layer)
	
	new_layer.load_in(layer_data)
	layers.insert(at, new_layer)
	emit_signal("layer_added", layer_data)
	
	if add_to_data:
		CurrentLevelData.current_area.layers.insert(at, layer_data)

	return new_layer

func remove_layer(index: int, remove_from_data: bool = false):
	var removed = layers[index]
	layers.remove(index)
	removed.queue_free()
	if remove_from_data:
		CurrentLevelData.current_area.layers.remove(index)
		
func edit_layer(index: int, property: String, value):
	var layer: LevelLayer = layers[index]
	var layer_data: LayerData = layer.layer_data
	
	layer_data.layer_metadata[property] = value
	layer.load_in(layer_data)
	CurrentLevelData.current_area.layers[index] = layer_data
	
func set_tile(x: int, y: int, index: int, tileset_id: int, tile_id: int, palette_id : int = 0):
	layers[index].place_tile(Vector2(x, y), tileset_id, tile_id, palette_id, true, true)

func get_tile(x: int, y: int, index: int):
	return layers[index].tile_map_manager.layer_data.tile_data.get_tile_data_at(Vector2(x, y))

func is_air(tile_data: Array):
	return tile_data[0] <= 0 or tile_data[1] < 0 or tile_data[2] < 0

func create_object(object: ObjectData, index: int, add_to_data = false):
	return layers[index].place_object(object, add_to_data)

func get_objects_manager(index: int):
	return layers[index].object_manager
	
func get_tile_map_manager(index: int):
	return layers[index].tile_map_manager
	
func get_object_at_position(pos: Vector2, index: int):
	return layers[index].get_object_at_position(pos)
