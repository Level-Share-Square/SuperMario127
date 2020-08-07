extends AudioStreamPlayer

export var play_bus: String
export var edit_bus: String

var character = null
var character2 = null

onready var temporary_music_player = $TemporaryMusicPlayer
onready var tween = $Tween

export var volume_multiplier : float = 1
export var loading = false
var base_volume = 0
var stored_volume #used when playing temporary music to return the volume afterwards

var last_mode = 3
var last_song = 0

var dl_ready = false
var downloader = Downloader.new()

var song_cache = []
var loop = 0.0

var muted = false

const MUSIC_FADE_LENGTH = 0.75

func get_song(song_id: int):
	return song_cache[song_id]

func _ready():
	base_volume = volume_db
	var _connect = downloader.connect("request_completed", self, "load_ogg")
	var level_songs : IdMap  = preload("res://assets/music/ids.tres")
	for id in level_songs.ids:
		song_cache.append(load("res://assets/music/resources/" + id + ".tres"))

	temporary_music_player.connect("finished", self, "stop_temporary_music")
	
func is_tween_active():
	return tween.is_active()
	
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
		var level_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
		if current_scene.mode != last_mode or typeof(last_song) != typeof(level_song):
			change_song(last_song, level_song)
		elif last_song != current_song:
			change_song(last_song, level_song)
		last_mode = current_scene.mode
		last_song = level_song
	
		volume_db = linear2db(db2linear(base_volume) * volume_multiplier) if !muted else -80

func _unhandled_input(event):
	if event.is_action_pressed("mute"):
		muted = !muted

# the plan for this is to mute the current bgm, play the temp song, and then fade the current bgm back in
func play_temporary_music(temp_song_id : int = 0, temp_song_volume : float = 0):
	volume_multiplier = 0

	tween.stop_all()
	temporary_music_player.stream = get_song(temp_song_id).stream
	temporary_music_player.volume_db = temp_song_volume
	temporary_music_player.play()

# returns the id of the temporary song
func is_temporary_music_playing():
	return temporary_music_player.playing

#can be called manually, also automatically called if the temporary music ends
func stop_temporary_music(volume_multipler_target = 1, music_fade_length = MUSIC_FADE_LENGTH):
	tween.interpolate_property(temporary_music_player, "volume_db", null, -80, music_fade_length, \
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_callback(temporary_music_player, MUSIC_FADE_LENGTH, "stop")
	tween.interpolate_property(self, "volume_multiplier", null, volume_multipler_target, music_fade_length, \
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
