extends AudioStreamPlayer

export var play_bus: String
export var edit_bus: String

export var volume_multiplier : float = 1
export var loading = false
var orig_volume = 0

var last_mode = 3
var last_song = 0

var dl_ready = false
var downloader = Downloader.new()

func get_song(song_id: int):
	var level_songs : IdMap  = preload("res://assets/music/ids.tres")
	var song : LevelSong = load("res://assets/music/resources/" + level_songs.ids[song_id] + ".tres")
	return song

func _ready():
	orig_volume = volume_db
	var _connect = downloader.connect("request_completed", self, "load_ogg")
	
func load_ogg():
	var path = "user://bg_music.ogg"
	var ogg_file = File.new()
	ogg_file.open(path, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	stream.loop = true
	if stream.data == null:
		return
	ogg_file.close()
	self.stream = stream
	play()
	print("Audio Loaded!")
	
func change_song(old_setting):
	var music_setting = CurrentLevelData.level_data.areas[0].settings.music
	var song
	
	if typeof(music_setting) == TYPE_INT:
		song = get_song(music_setting)
	elif typeof(music_setting) == TYPE_STRING:
		if typeof(music_setting) != typeof(old_setting) or music_setting != old_setting:
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
	var current_song = CurrentLevelData.level_data.areas[0].settings.music
	if loading and OS.has_feature("JavaScript"):
		AudioServer.set_bus_mute(0, true)
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_mute(1, false)
	if get_tree().get_current_scene().mode != last_mode or typeof(last_song) != typeof(current_song):
		change_song(last_song)
	elif last_song != current_song:
		change_song(last_song)
	volume_db = linear2db(db2linear(orig_volume) * volume_multiplier)
	last_mode = get_tree().get_current_scene().mode
	last_song = CurrentLevelData.level_data.areas[0].settings.music

func _unhandled_input(event):
	if event.is_action_pressed("mute"):
		volume_multiplier = 0 if volume_multiplier == 1 else 1
