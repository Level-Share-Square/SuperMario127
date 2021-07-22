class_name terrain_generator

static func generate(noise_seed, shared_node):
	var noise = OpenSimplexNoise.new()
	noise.seed = noise_seed
	noise.octaves = 8
	noise.period = 20
	noise.persistence = 0.2
	
	var decor_array = []
	var ids = load("res://generation/decorations/grass/decorations.tres").ids
	for id in ids:
		decor_array.append(load("res://generation/decorations/grass/" + id + ".gd").new())
	
	var set = false
	var set2 = false
	var level_area = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area]
	for object in shared_node.get_objects_node().get_children():
		shared_node.destroy_object(object, true)
	for x in range(level_area.settings.bounds.size.x):
		for y in range(level_area.settings.bounds.size.y):
			
			var tile = 0
			if noise.get_noise_2d(x, y) > 0:
				tile = 2
			shared_node.set_tile(x, y, 1, tile, 0)
			
			for decoration in decor_array:
				if rand_range(0, 100) < decoration.chance_percentage:
					if decoration.placement_check(tile, Vector2(x, y), noise, shared_node):
						if decoration.object_id != 4:
							print("B")
						_spawn_object(shared_node, x, y, decoration.object_id)
			
			if rand_range(0.01, 1) > 0.95 and y > 3 and !set and level_area.objects.size() > 0:
				if tile == 2 and noise.get_noise_2d(x, y - 1) <= 0 and noise.get_noise_2d(x, y - 2) <= 0:
					set = true
					_spawn_object(shared_node, x, y, 0)
			
			elif rand_range(0.01, 1) > 0.75 and y > 3 and !set2 and level_area.objects.size() > 1:
				if tile == 2 and noise.get_noise_2d(x, y - 1) <= 0 and noise.get_noise_2d(x, y - 2) <= 0:
					set2 = true
					_spawn_object(shared_node, x, y, 5)
					
					
	noise.seed = randi()
	noise.octaves = 8
	noise.period = 20
	noise.persistence = 0.2
	for x in range(level_area.settings.bounds.size.x):
		for y in range(level_area.settings.bounds.size.y):
			var tile = 0
			if noise.get_noise_2d(x, y) > 0:
				tile = 2
			shared_node.set_tile(x, y, 0, tile, 0)
													   # =========================================
static func _spawn_object(shared_node, x, y, type_id): # | This was created to remove the      ▲ |
	var object := LevelObject.new()                    # | redundancy in the `if` blocks above | |
	object.type_id = type_id                           # =========================================
	object.properties = []
	object.properties.append(Vector2((x * 32) + 16, (y * 32) + 3))
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	shared_node.create_object(object, true)
