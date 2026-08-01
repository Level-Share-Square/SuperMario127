class_name MoveTilesAction
extends Action

var shared: LevelShared

var map_state_old: Dictionary = {}
var map_state_new: Dictionary = {}
var layer: int

func move_tiles(map_state):
	for pos in map_state:
		var tile = map_state[pos]
		shared.set_tile(pos.x, pos.y, layer, tile[0], tile[1], tile[2])

func find_map_state(old_tiles, new_tiles):
	for pos in old_tiles:
		map_state_old[pos] = old_tiles[pos]
		map_state_new[pos] = [0, 0, 0]
		
	for pos in new_tiles:
		if !map_state_old.has(pos):
			map_state_old[pos] = shared.get_tile(pos.x, pos.y, layer)
		map_state_new[pos] = new_tiles[pos]

func _do() -> void:
	move_tiles(map_state_new)

func _undo() -> void:
	move_tiles(map_state_old)
