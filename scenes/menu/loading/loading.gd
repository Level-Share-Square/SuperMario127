extends Node2D

onready var coins_text = $Text/Coins
onready var coins_shadow = $Text/Coins/Shadow

onready var loading_text = $Text/Loading
onready var loading_shadow = $Text/Loading/Shadow

onready var animation_player = $AnimationPlayer
onready var luigi_frames = preload("res://scenes/actors/mario/luigi_frames.tres")

onready var mario_sprite = $Sprites/Player/AnimatedSprite
onready var mario_reflection = $Sprites/Player/Reflection

onready var coin_sound = $CoinSound
onready var coin_scene = preload("res://scenes/menu/loading/coin.tscn")

var resource_loader

onready var amount_of_scenes = Singleton.load_paths.size() * 2
onready var thread = Thread.new()

var current_index = 0
var percentage = 0
var coins = 0
var coins_spawned = 0

var spawn_timer = 0.0
var done = false

func go_to_menu():
	if !Singleton.loaded:
		Singleton.loaded = true
		var number_of_tiles = load("res://assets/tiles/tiles.tres").get_last_unused_tile_id()
		if !(number_of_tiles == Singleton.EditorSavedSettings.data_tiles and ResourceLoader.exists("user://tiles.res", "TileSet")):
			Singleton.EditorSavedSettings.tileset_loaded = true
			Singleton.EditorSavedSettings.data_tiles = number_of_tiles
			var _reload_scene = get_tree().reload_current_scene()
		else:
			var _change_scene = get_tree().change_scene("res://scenes/menu/main_menu_controller/main_menu_controller.tscn")
	else:
		var _change_scene = get_tree().change_scene("res://scenes/menu/main_menu_controller/main_menu_controller.tscn")

func _ready():
	animation_player.play("FadeIn")
#	yield(get_tree().create_timer(5), "timeout")
	if !Singleton.loaded:
		thread.start(self, "load_singletons", null, thread.PRIORITY_HIGH)
	else:
		loading_text.text = "Creating tile data..."
		loading_shadow.text = loading_text.text
		
		mario_sprite.frames = luigi_frames
		mario_reflection.frames = luigi_frames
		thread.start(self, "load_palettes", null, thread.PRIORITY_HIGH)

func collect_coin(play_sound = true):
	coins += 1
	if play_sound:
		coin_sound.play()
	
	coins_text.text = str(coins).pad_zeros(3) + "/100"
	coins_shadow.text = coins_text.text

func _physics_process(delta):
	if stepify(percentage * 100, 1) > coins_spawned and spawn_timer <= 0:
		if coins_spawned != 33 and coins_spawned != 66 and coins_spawned < 95:
			var coin_object = coin_scene.instance()
			coin_object.rect_position = Vector2(768, 330)
			$Sprites.add_child(coin_object)
		coins_spawned += 1
		spawn_timer = 0.05
	
	if spawn_timer > 0:
		spawn_timer -= delta

func load_palettes(userdata):
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	var tileset_resource = preload("res://assets/tiles/tiles.tres")
	var number_of_tiles = tileset_resource.get_last_unused_tile_id()
	
	var tileset_palettes = []

	Singleton.EditorSavedSettings.data_tiles = number_of_tiles
	Singleton.EditorSavedSettings.tileset_loaded = true
	
	for tileset_id in level_tilesets.ids:
		var tileset : LevelTileset = load("res://assets/tiles/" + tileset_id + "/resource.tres")
		var tile_variations = [
			tileset.block_tile_id,
			tileset.slab_tile_id,
			tileset.left_slope_tile_id,
			tileset.right_slope_tile_id
		]
		
		var palette_ids = []
		for palette in tileset.palettes:
			var tile_variation_ids = []
			for base_tile_id in tile_variations:
				var new_tile_id = tileset_resource.get_last_unused_tile_id()
				tileset_resource.create_tile(new_tile_id)
				
				tileset_resource.autotile_set_bitmask_mode(new_tile_id, tileset_resource.autotile_get_bitmask_mode(base_tile_id))
				tileset_resource.autotile_set_size(new_tile_id, tileset_resource.autotile_get_size(base_tile_id))
				tileset_resource.tile_set_tile_mode(new_tile_id, tileset_resource.tile_get_tile_mode(base_tile_id))
				
				var region =  tileset_resource.tile_get_region(base_tile_id)
				for coord_x in range(region.size.x):
					for coord_y in range(region.size.y):
						var coord = Vector2(coord_x, coord_y)
						tileset_resource.autotile_set_bitmask(new_tile_id, coord, tileset_resource.autotile_get_bitmask(base_tile_id, coord))
				
				tileset_resource.tile_set_region(new_tile_id, region)
				tileset_resource.tile_set_texture(new_tile_id, palette)
				tileset_resource.tile_set_texture_offset(new_tile_id, tileset_resource.tile_get_texture_offset(base_tile_id))
				tileset_resource.tile_set_shapes(new_tile_id, tileset_resource.tile_get_shapes(base_tile_id))
				
				tile_variation_ids.append(new_tile_id)
			palette_ids.append(tile_variation_ids)
		tileset_palettes.append(palette_ids)
		
		percentage = float(current_index) / float(level_tilesets.ids.size())
		current_index += 1
		print("Loaded tileset " + str(current_index))
	
	tileset_resource._init()
	Singleton.EditorSavedSettings.tileset_palettes = tileset_palettes
	ResourceSaver.save("user://tiles.res", tileset_resource)
	Singleton.EditorSavedSettings.tiles_resource = tileset_resource
	SettingsSaver.save()
	
	percentage = 1
	print("Finished loading all " + str(level_tilesets.ids.size()) + " tilesets.")

func load_singletons(userdata):
	for scene in Singleton.load_paths:
		var loaded = false
		resource_loader = ResourceLoader.load_interactive(scene[1])
		while !loaded:
			if resource_loader.poll() == ERR_FILE_EOF:
				Singleton[scene[0]] = resource_loader.get_resource()
				
				percentage = float(current_index) / float(amount_of_scenes)
				current_index += 1
				loaded = true
				print("Loaded scene " + str(current_index))
			else:
				yield(get_tree().create_timer(0.35), "timeout")
	
	for scene in Singleton.load_paths:
		var instanced_scene = Singleton[scene[0]].instance()
		Singleton[scene[0]] = instanced_scene
		get_tree().root.add_child(Singleton[scene[0]])
		
		percentage = float(current_index) / float(amount_of_scenes)
		current_index += 1
		print("Instanced scene " + str(current_index - (amount_of_scenes/2)))
		
		yield(get_tree().create_timer(0.35), "timeout")
	
	done = true
	percentage = 1
	
	print("Finished loading all " + str(amount_of_scenes / 2) + " scenes.")
