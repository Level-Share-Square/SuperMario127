extends Node2D


const TEST_CODE_PATH = "res://level/data/test/test_code.txt"
const PLAYER_PATH = preload("res://scenes/player/player.tscn")
const EDITOR_PATH = preload("res://scenes/editor/editor.tscn")


func _ready():
#	test_level_code_validation()
	convert_debug_level()
	
#	instance_debug_level()
	
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
	
#	collectible_data_storage_test(
#		CollectibleData.new(
#			[
#				MissionData.new(uuid_util.v4(), true, "Test 1", "Desc 1", 0),
#				MissionData.new(uuid_util.v4(), true, "Test 2", "Desc 2", 2),
#			],
#			[
#				StarCoinData.new(uuid_util.v4()),
#				StarCoinData.new(uuid_util.v4()),
#			]
#		)
#	)


func load_file():
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func test_level_code_validation():
	var invalid_1 = get_path_as_text("res://level/data/test/invalid_level_1.txt")
	var invalid_2 = get_path_as_text("res://level/data/test/invalid_level_2.txt")
	var invalid_3 = get_path_as_text("res://level/data/test/invalid_level_3.txt")
	print(level_code_validator_util.validate_level_code(invalid_1))
	print(level_code_validator_util.validate_level_code(invalid_2))
	print(level_code_validator_util.validate_level_code(invalid_3))
	pass


func get_path_as_text(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func instance_debug_level():
	var TEST_CODE_PATH = "res://level/data/test/archipelago_old.txt"
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()

	CurrentLevelData.load_level_headers(content)
	CurrentLevelData.switch_to_area(0)
	get_tree().change_scene_to(EDITOR_PATH)


func convert_debug_level():
	var TEST_CODE_PATH = "res://level/data/test/archipelago_old.txt"
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	var new_code: String = CurrentLevelData.convert_old_code_to_new(content)
	
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


func collectible_data_storage_test(collectible_data: CollectibleData):
	print(collectible_data.mission_data)
	print(collectible_data.star_coin_data)
	
	var code: String = LevelCodeSerializer.serialize_collectible_data(collectible_data)
	collectible_data = LevelCodeDeserializer.deserialize_collectible_data_code(code)
	
	print(collectible_data.mission_data)
	print(collectible_data.star_coin_data)
