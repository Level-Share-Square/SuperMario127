tool
extends TileSet

var binds = {
}

func _is_tile_bound(id, nid):
	if id > binds.size(): return
	return nid in binds[id] 

func _init():
	var amount_of_ids = get_last_unused_tile_id()
	for id in range(amount_of_ids):
		var id_array = []
		for id2 in range(amount_of_ids):
			if id2 != id:
				id_array.append(id2)
		binds[id] = id_array
