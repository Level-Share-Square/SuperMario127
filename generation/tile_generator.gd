extends Control

var number_of_tiles = 0
var current_index = 0

onready var thread: Thread = Thread.new()
func _ready():
	thread.start(self, "load_tilesets", null, Thread.PRIORITY_HIGH)

func load_tilesets():
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	var tileset_resource = preload("res://assets/tiles/tiles.tres")
	var tileset_palettes = []
	
	number_of_tiles = tileset_resource.get_last_unused_tile_id()
	for tileset_id in level_tilesets.ids:
		var tileset : LevelTileset = load("res://assets/tiles/" + tileset_id + "/resource.tres")
		print("Setting up tile ", str(current_index), " - ", tileset.palettes.size(), " palettes")
		var tile_variations = [
			tileset.block_tile_id,
			tileset.slab_tile_id,
			tileset.left_slope_tile_id,
			tileset.right_slope_tile_id
		]
		
		var palette_ids = []
		palette_ids.resize(tileset.palettes.size())
		var palette_ids_i := 0
		for palette in tileset.palettes:
			var tile_variation_ids = []
			tile_variation_ids.resize(tile_variations.size())
			print(tile_variations)
			var tile_variations_i := 0
			for base_tile_id in tile_variations:
				var new_tile_id = tileset_resource.get_last_unused_tile_id()
				tileset_resource.create_tile(new_tile_id)
				
				tileset_resource.autotile_set_bitmask_mode(new_tile_id, tileset_resource.autotile_get_bitmask_mode(base_tile_id))
				tileset_resource.autotile_set_size(new_tile_id, tileset_resource.autotile_get_size(base_tile_id))
				tileset_resource.tile_set_tile_mode(new_tile_id, tileset_resource.tile_get_tile_mode(base_tile_id))
				
				var region =  tileset_resource.tile_get_region(base_tile_id)
				for coord_x in range(region.size.x):
					for coord_y in range(region.size.y):
						var coord := Vector2(coord_x, coord_y)
						tileset_resource.autotile_set_bitmask(new_tile_id, coord, tileset_resource.autotile_get_bitmask(base_tile_id, coord))
				
				tileset_resource.tile_set_region(new_tile_id, region)
				tileset_resource.tile_set_texture(new_tile_id, palette)
				tileset_resource.tile_set_texture_offset(new_tile_id, tileset_resource.tile_get_texture_offset(base_tile_id))
				tileset_resource.tile_set_shapes(new_tile_id, tileset_resource.tile_get_shapes(base_tile_id))
				
				tile_variation_ids[tile_variations_i] = new_tile_id
				tile_variations_i += 1
			
			palette_ids[palette_ids_i] = tile_variation_ids
			palette_ids_i += 1
		tileset_palettes.append(palette_ids)
		
		current_index += 1
		$Label.text = "Tiles: " + str(current_index) + "/" + str(level_tilesets.ids.size())
		print("Loaded tileset " + str(current_index))
	
	ResourceSaver.save("res://generation/generated_tiles.res", tileset_resource)
	
	var palette_storage := Resource.new()
	palette_storage.set_script(preload("res://generation/palettes.gd"))
	palette_storage.tileset_palettes = tileset_palettes
	ResourceSaver.save("res://generation/tileset_palettes.res", palette_storage)
	
	$Label.text = "Tiles resource saved to res://generation/generated_tiles.res"
	print("Finished loading all " + str(level_tilesets.ids.size()) + " tilesets.")
