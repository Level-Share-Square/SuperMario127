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
var button_pressed = false

onready var reset_mod = $ResetMod

onready var amount_of_scenes = Singleton.load_paths.size()
onready var thread = Thread.new()
onready var file = File.new()
onready var dir = Directory.new()

var current_index = 0
var percentage = 0
var coins = 0
var coins_spawned = 0
var spawn_timer = 0.0
var done = false

func go_to_menu():
	while Singleton.EditorSavedSettings.loading_tileset:
		yield(get_tree(), "idle_frame")
	
	if !Singleton.loaded:
		Singleton.loaded = true
		var number_of_tiles = load("res://assets/tiles/tiles.tres").get_last_unused_tile_id()
		if !(number_of_tiles == Singleton.EditorSavedSettings.data_tiles and ResourceLoader.exists("user://tiles.res", "TileSet")):
			Singleton.EditorSavedSettings.tileset_loaded = true
			Singleton.EditorSavedSettings.data_tiles = number_of_tiles
			var _reload_scene = get_tree().reload_current_scene()
		else:
			Singleton.MenuVariables.quit_to_menu()
	else:
		Singleton.MenuVariables.quit_to_menu()
		
static func get_data_or_null():
	var file = File.new()
	file.open("user://settings.json", File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		return data
	else:
		return null
		
func _ready():
	if Singleton2.mod_active == true:
		reset_mod.show()
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(reset_mod, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2.5, Tween.EASE_IN)
		tween.start()
	else:
		reset_mod.hide()
	reset_mod.connect("button_down", self, "reset_mod")
	var data = get_data_or_null()
	if data != null:
		if data.has("richpresence"):
			Singleton2.rp = data["richpresence"]
		if data.has("darkmode"):
			Singleton2.dark_mode = data["darkmode"]
	if Singleton2.dark_mode:
		$Background/ColorRect.visible = false
		$Background/TextureRect.visible = false
		$Text/Loading.modulate = Color(1,1,1)
		$Text/Coins.modulate = Color(1,1,1)
		$Foreground/ColorRect.color = Color(0,0,0,1)
	dir.make_dir("user://replays")
	dir.make_dir("user://autosave")
	dir.make_dir("user://mods")
	if !file.file_exists("user://081.dmitri"):
		dir.remove("user://tiles.res")
		dir.remove("user://bg_music.ogg")
		dir.remove("user://settings.json")
		OS.move_to_trash(ProjectSettings.globalize_path("user://template_levels"))
		file.open("user://081.dmitri", File.WRITE)
		file.close()
		dir.remove("user://080.darius")
	if Singleton2.rp == true:
		update_activity()
	elif Singleton2.rp == false:
		if Singleton2.dead == false:
			Discord.queue_free()
			Singleton2.dead = true
		elif Singleton2.dead == true:
			pass
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
		dir.make_dir("user://hotkeys")
		file.open("user://hotkeys/defhotkeys.file", File.WRITE)
		var dict = {}
		for i in Singleton2.default_hotkeys:
			dict[i] = InputMap.get_action_list(i)[0].get_scancode()
		file.store_var(dict)
		file.close()

func reset_mod():
	var dir = Directory.new()
	dir.remove("user://mods/active.127mod")
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit(0)

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

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("Loading...")

	var assets = activity.get_assets()
	assets.set_large_image("sm127")
	assets.set_large_text("0.8.0")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 1)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))
		

func load_palettes(_userdata):
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	var tileset_resource = preload("res://assets/tiles/tiles.tres")
	var number_of_tiles = tileset_resource.get_last_unused_tile_id()
	
	var tileset_palettes = []

	Singleton.EditorSavedSettings.data_tiles = number_of_tiles
	Singleton.EditorSavedSettings.tileset_loaded = true
	
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

func load_singletons(_userdata):
	var ms_start := OS.get_ticks_msec()
	
	# First 25% = load singletons
	for scene in Singleton.load_paths:
		resource_loader = ResourceLoader.load_interactive(scene[1])
		
		while true:
			OS.delay_msec(1)
			
			if resource_loader.poll() == ERR_FILE_EOF:
				Singleton[scene[0]] = resource_loader.get_resource()
				
				print("Loaded scene " + str(current_index + 1))
				break
		
		var instanced_scene = Singleton[scene[0]].instance()
		Singleton[scene[0]] = instanced_scene
		Singleton.add_child(Singleton[scene[0]])
		
		current_index += 1
		percentage = float(current_index) / float(amount_of_scenes) * 0.25
		print("Instanced scene " + str(current_index))
	
	var ms_end := OS.get_ticks_msec()
	print("Finished loading all " + str(amount_of_scenes) + " singletons in ", str(ms_end - ms_start), " ms")
	
	# Last 75% = load scenes within the singletons
	var loading_nodes := [Singleton.MiscCache, Singleton.CurrentLevelData]
	var loaded_ids_sum := 0
	var loaded_max_sum := 1 # to be able to enter the loop
	
	while loaded_ids_sum < loaded_max_sum:
		OS.delay_msec(1)
		
		loaded_ids_sum = 0
		loaded_max_sum = 0
		for node in loading_nodes:
			loaded_ids_sum += node.loaded_ids
			loaded_max_sum += node.loaded_ids_max
		
		#var previous_percentage = percentage
		percentage = 0.25 + (float(loaded_ids_sum) / float(loaded_max_sum) * 0.75)
		#if previous_percentage != percentage:
		#	print(loaded_ids_sum, " / ", loaded_max_sum, " loaded")
	
	done = true
	
	#used to display the skip button once all singletons have loaded
	if(done == true):
		animation_player.play("buttonIn")
	percentage = 1
	print("Finished loading all scenes within the singletons")
