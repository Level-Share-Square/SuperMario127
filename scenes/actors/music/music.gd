extends AudioStreamPlayer

export var play_bus: String
export var edit_bus: String

var character = null
var character2 = null

export var volume_multiplier : float = 1
export var loading = false
var orig_volume = 0

var last_mode = 3
var last_song = 0

var dl_ready = false
var downloader = Downloader.new()

var song_cache = []
var loop = 0.0

var is_powerup = false

func get_song(song_id: int):
	return song_cache[song_id]

func _ready():
	orig_volume = volume_db
	var _connect = downloader.connect("request_completed", self, "load_ogg")
	var level_songs : IdMap  = preload("res://assets/music/ids.tres")
	for id in level_songs.ids:
		song_cache.append(load("res://assets/music/resources/" + id + ".tres"))
	
func load_ogg():
	var path = "user://bg_music.ogg"
	var ogg_file = File.new()
	ogg_file.open(path, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	stream.loop = true
	stream.loop_offset = loop
	if stream.data == null:
		return
	ogg_file.close()
	self.stream = stream
	play()
	print("Audio Loaded!")
	
func change_song(old_setting, music_setting):
	var song
	
	if typeof(music_setting) == TYPE_INT:
		song = get_song(music_setting)
	elif typeof(music_setting) == TYPE_STRING:
		if typeof(music_setting) != typeof(old_setting) or music_setting != old_setting:
			loop = 0.0
			if music_setting.begins_with("LP"):
				loop = float(music_setting.trim_prefix("LP").split("=")[0])
				print(str(loop))
			stop()
			downloader.download(music_setting, "user://", "bg_music.ogg")
	
	if song != null:
		if stream != song.stream:
			stream = song.stream
			play()
	if get_tree().get_current_scene().mode == 0:
		bus = play_bus
	else:
		bus = edit_bus

func _process(_delta):
	var current_scene = get_tree().get_current_scene()
	var current_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
	
	if "mode" in current_scene: #script will crash if the scene root doesn't have this property defined
		if !is_powerup:
			var level_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
			if current_scene.mode != last_mode or typeof(last_song) != typeof(level_song):
				change_song(last_song, level_song)
			elif last_song != current_song:
				change_song(last_song, level_song)
			last_mode = current_scene.mode
			last_song = level_song
	
		volume_db = linear2db(db2linear(orig_volume) * volume_multiplier)
	
		if current_scene.mode == 0 and is_instance_valid(character):
			if character.powerup != null:
				if (typeof(current_song) == TYPE_INT and character.powerup.music_id != current_song) or typeof(current_song) != TYPE_INT:
					last_song = current_song
					current_song = character.powerup.music_id
					change_song(last_song, current_song)
					is_powerup = true
			else:
				if is_powerup:
					last_song = current_song
					var level_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
					current_song = level_song
					change_song(last_song, level_song)
				is_powerup = false
		else:
			if is_powerup:
				last_song = current_song
				var level_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
				current_song = level_song
				change_song(last_song, level_song)
			is_powerup = false

func _unhandled_input(event):
	if event.is_action_pressed("mute"):
		volume_multiplier = 0 if volume_multiplier == 1 else 1
