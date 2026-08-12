class_name LayerData
extends LevelDataResource


var layer_metadata: LayerMetadata
var tile_data: TileData
var object_data: Array


# Called when the node enters the scene tree for the first time.
func _init(set_layer_metadata: LayerMetadata, set_tile_data: TileData, set_object_data: Array = []):
	layer_metadata = set_layer_metadata
	object_data = set_object_data
	tile_data = set_tile_data

static func duplicate_metadata(other: LayerMetadata) -> LayerMetadata:
	return LayerMetadata.new(
		other.parallax_distance,
		other.parallax_offset,
		other.autoset_tint,
		other.layer_tint,
		other.order,
		other.is_ground,
		other.layer_name,
		other.is_origin,
		other.activated_mission_ids,
		other.disabled,
		other.layer_opacity,
		other.layer_uuid
	)

func place_tile(coords: Vector2, tileset: int, type: int, palette: int = 0) -> void:
	tile_data.set_tile(coords, tileset, type, palette)


func erase_tile(coords: Vector2) -> void:
	tile_data.erase_tile(coords)


func add_object(data) -> void:
	object_data.append(data)
	
func erase_object(data) -> void:
	object_data.erase(data)


func place_object(position: Vector2, data: ObjectData):
	data.metadata.position = position
	add_object(data)

static func tiles_to_tile_data(tiles: Dictionary, chunks: Dictionary) -> TileData:
	var tile_data := TileData.new()
	for position in tiles:
		var chunk_pos = tile_data.get_chunk_coords(position)
		
		if !tile_data.chunks.has(chunk_pos):
			var chunk = PoolIntArray()
			chunk.resize(TileData.TILE_CHUNK_SIZE * TileData.TILE_CHUNK_SIZE)
			chunk.fill(0)
			tile_data.set_chunk_data(chunk_pos, chunk)
			
		tile_data.set_tile(position, tiles[position][0], tiles[position][1], tiles[position][2])
	return tile_data
