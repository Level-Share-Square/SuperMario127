extends LevelDataLoader
class_name LevelShared

const GROUND_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/ground_layer/ground_layer.tscn"
const PARALLAX_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/parallax_layer/parallax_layer.tscn"

var ground_layer_scene: PackedScene = preload(GROUND_LAYER_SCENE_PATH)
var parallax_layer_scene: PackedScene = preload(PARALLAX_LAYER_SCENE_PATH)

var layers: Array
var origin: LevelGroundLayer
var layer_dictionary: Dictionary = {}

var tile_objects: Array = []

const layer_index_offset: int = -2
const layer_spacing: int = 16

export var boo_block_texture = "res://assets/tiles/boo_block/boo_block.png"
export var boo_block_texture_invis = "res://assets/tiles/boo_block/boo_block_invis.png"

onready var loaded_boo_texture = load(boo_block_texture)
onready var loaded_boo_texture_invis = load(boo_block_texture_invis)

signal layer_added(layer)
signal layer_moved
signal found_origin
signal loaded_layers

func load_in():
	load_layers(CurrentLevelData.current_area.layers)
	var tex = loaded_boo_texture
	if get_tree().get_current_scene().mode == 0:
		tex = loaded_boo_texture_invis
	for i in [18, 118, 119]:
		get_layer(layers[0]).tile_map_manager.tile_set.tile_set_texture(i, tex)
	emit_signal("loaded_layers")

func load_layers(layer_data_list: Array):
	for layer_data in layer_data_list:
		layer_data = layer_data
		var layer: LevelLayer = add_layer(layer_data)
		
		if layer.layer_data.layer_metadata.is_origin:
			origin = layer
			emit_signal("found_origin", origin.layer_data.layer_metadata.order)
			
	# This is a failsafe in case none of the layers are origin
	if !origin:
		origin = get_layer(layers[2])
		emit_signal("found_origin", origin.layer_data.layer_metadata.order)

func get_layer_index(layer: LevelLayer):
	return layer.layer_data.layer_metadata.order
	
func get_layer_at(index: int) -> LevelLayer:
	return get_layer(layers[index])
	
func get_layer(uuid: String) -> LevelLayer:
	return layer_dictionary.get(uuid)

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
	
	var uuid: String = layer_data.layer_metadata.layer_uuid
	
	new_layer.load_in(layer_data)
	layers.insert(at, uuid)
	layer_dictionary.get_or_add(uuid, new_layer)
	emit_signal("layer_added", layer_data)
	
	if add_to_data:
		CurrentLevelData.current_area.layers.insert(at, layer_data)

	return new_layer

func remove_layer(uuid: String, remove_from_data: bool = false):
	var removed = get_layer(uuid)
	layers.erase(uuid)
	layer_dictionary.erase(uuid)
	removed.queue_free()
	if remove_from_data:
		CurrentLevelData.current_area.layers.remove(get_layer_index(removed))
		for i in range(0, CurrentLevelData.current_area.layers.size()):
			CurrentLevelData.current_area.layers[i].layer_metadata.order = i
		
func layer_index_to_uuid(index: int):
	return layer_dictionary.find_key(get_layer_at(index))
		
func edit_layer(uuid: String, property: String, value):
	var layer: LevelLayer = get_layer(uuid)
	var layer_data: LayerData = layer.layer_data
	
	layer_data.layer_metadata[property] = value
	layer.load_in(layer_data)
	CurrentLevelData.current_area.layers[get_layer_index(layer)] = layer_data
	
func move_layer(layer: LevelLayer, to: int, save_to_data: bool = false):
	var from: int = layer.get_index()
	move_child(layer, to)
	for i in range(min(from, to), max(from, to) + 1):
		get_child(i).set_order(i)
		if save_to_data:
			edit_layer(layer_index_to_uuid(i), "order", i)
	emit_signal("layer_moved")
			
func load_layer_states(layer_states: Dictionary):
	var layers_to_move: Array = []
	
	for layer_uuid in layer_states:
		var layer: LevelLayer = get_layer(layer_uuid)
		var layer_state: LayerState = layer_states[layer_uuid]
		
		if layer is LevelParallaxLayer:
			layer.set_parallax_distance(layer_state.parallax_distance)
		layer.set_layer_modulate(layer_state.tint, layer_state.opacity)
		layer.visible = layer_state.is_visible
		
		if layer_state.order != -1:
			layers_to_move.append([layer, layer_state.order])
		
		layers_to_move.sort_custom(self, "sort_by_order")
		
		for layer_array in layers_to_move:
			move_layer(layer_array[0], layer_array[1])
			
	
func sort_by_order(a: Array, b: Array):
	return a[1] < b[1]
	
func set_tile(x: int, y: int, uuid: String, tileset_id: int, tile_id: int, palette_id : int = 0):
	layer_dictionary[uuid].place_tile(Vector2(x, y), tileset_id, tile_id, palette_id, true, true)

func get_tile(x: int, y: int, uuid: String):
	return layer_dictionary[uuid].tile_map_manager.layer_data.tile_data.get_tile_data_at(Vector2(x, y))

func is_air(tile_data: Array):
	return tile_data[0] <= 0 or tile_data[1] < 0 or tile_data[2] < 0

func create_object(object: ObjectData, uuid: String, add_to_data = false):
	return layer_dictionary[uuid].place_object(object, add_to_data)

func get_objects_manager(uuid: String):
	return layer_dictionary[uuid].object_manager
	
func get_tile_map_manager(uuid: String):
	return layer_dictionary[uuid].tile_map_manager
	
func get_object_at_position(pos: Vector2, uuid: String):
	return layer_dictionary[uuid].get_object_at_position(pos)

func update_tilemaps():
	for layer in layer_dictionary.values():
		layer.tile_map_manager.load_in(layer.layer_data)

func focus_layer(focus: bool, focus_layer: String):
	for layer_uuid in layers:
		var layer = get_layer(layer_uuid)
		if focus:
			layer.visible = layer_uuid == focus_layer
		else:
			layer.visible = layer.layer_data.layer_metadata.layer_visible
