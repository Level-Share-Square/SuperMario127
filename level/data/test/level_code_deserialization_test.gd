extends Node2D


const TEST_CODE_PATH = "res://level/data/test/test_code.txt"
const PLAYER_PATH = preload("res://scenes/player/player.tscn")


func _ready():
#	instance_debug_level()
	
	convert_debug_level()
	
#	tile_byte_test(
#		{
#			Vector2(-16, 0): [1, 0, 0],
#			Vector2(-16, 1): [1, 0, 0],
#			Vector2(-16, 2): [1, 0, 0],
#			Vector2(0, 3): [1, 0, 0],
#			Vector2(0, 4): [1, 0, 0],
#			Vector2(0, 5): [1, 0, 0],
#			Vector2(16, 0): [1, 0, 0],
#			Vector2(16, 1): [1, 0, 0],
#			Vector2(16, 2): [1, 0, 0],
#			Vector2(32, 3): [1, 0, 0],
#			Vector2(32, 4): [1, 0, 0],
#			Vector2(32, 5): [1, 0, 0],
#		}
#	)
	
#	base64_int_test([0, 1, 2, 3, 4, -1, -2, -3, -4])


func load_file():
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func instance_debug_level():
	var TEST_CODE_PATH = "res://level/data/test/archipelago_old.txt"
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	CurrentLevelData.load_level_headers(content)
	CurrentLevelData.load_level_area(0)
	get_tree().change_scene_to(PLAYER_PATH)


func convert_debug_level():
	var TEST_CODE_PATH = "res://level/data/test/archipelago_old.txt"
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	var new_code: String = CurrentLevelData.convert_old_code_to_new(content)
#	print(new_code)
	
	file.open("res://level/data/test/archipelago_new.txt", File.WRITE)
	file.store_string(new_code)
	file.close()


func tile_byte_test(tiles: Dictionary):
	var tile_data: TileData = TileData.new()
	
	for coord in tiles:
		tile_data.set_tile(coord, tiles[coord][0], tiles[coord][0], tiles[coord][0])
	
	var tile_bytes: PoolByteArray = tile_util.chunks_to_tile_bytes(tile_data.chunks)
	var chunks_from_bytes: Dictionary = tile_util.tile_bytes_to_chunks(tile_bytes)
	
	print("TileData chunks: ", tile_data.chunks)
	print("Tile bytes: ", tile_bytes)
	print("Chunks from bytes: ", chunks_from_bytes)


func base64_int_test(integers: PoolIntArray):
	for integer in integers:
		print("Value: ", integer)
		var encoded: String = LevelCodeSerializer.base64_encode_int(integer)
		print("Encoded: ", encoded)
		var decoded: int = LevelCodeDeserializer.base64_decode_int(encoded)
		print("Decoded: ", decoded)
