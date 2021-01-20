extends AudioStreamPlayer

export var play_bus : String
export var edit_bus : String

var character : Character
var character2 : Character

onready var temporary_music_player : AudioStreamPlayer = $TemporaryMusicPlayer
onready var water_music_player : AudioStreamPlayer = $WaterMusicPlayer
onready var tween : Tween = $Tween

export var volume_multiplier := 1.0
export var loading := false
var base_volume : float = 0
var stored_volume : float # used when playing temporary music to return the volume afterwards

var last_mode := 3
var last_song = 0 # this can't be static typed, can be either an int or a string

var dl_ready := false
var downloader := Downloader.new()

var song_cache := []
var loop := 1.0
var global_volume := 1.0

var muted := false
var play_water := false
var has_water := false
var temp_music := false

const MUSIC_FADE_LENGTH = 0.75

func get_song(song_id : int):
	return song_cache[song_id]

func _ready() -> void:
	base_volume = volume_db
	var _connect = downloader.connect("request_completed", self, "load_ogg")
	var level_songs : IdMap  = preload("res://assets/music/ids.tres")
	for id in level_songs.ids:
		song_cache.append(load("res://assets/music/resources/" + id + ".tres"))
	
	_connect = temporary_music_player.connect("finished", self, "stop_temporary_music")

func set_global_volume(new_volume: float) -> void:
	global_volume = clamp(new_volume, 0.0, 1.0)
	var new_db : float = 20 * log(global_volume)
	if new_db > 0: new_db = 0 # In case... I don't wanna get earraped again :(
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_db)
	SettingsSaver.save_volume()

func increment_global_volume(increment: float) -> void:
	set_global_volume(global_volume + increment)

func is_tween_active() -> bool:
	return tween.is_active()
	
func load_ogg() -> void:
	var path := "user://bg_music.ogg"

	var ogg_file := File.new()
	var _open = ogg_file.open(path, File.READ)
	var bytes := ogg_file.get_buffer(ogg_file.get_len())

	var stream := AudioStreamOGGVorbis.new()
	stream.data = bytes
	stream.loop = true
	stream.loop_offset = loop
	if stream.data == null:
		return

	ogg_file.close()

	if get_tree().get_current_scene().mode != 2:
		self.stream = stream
		play()

func change_song(old_setting, music_setting) -> void:
	var song
	
	if typeof(music_setting) == TYPE_INT:
		song = get_song(music_setting)
	elif typeof(music_setting) == TYPE_STRING:
		if typeof(music_setting) != typeof(old_setting) or music_setting != old_setting:
			loop = 0.0
			if music_setting.begins_with("LP"):
				loop = float(music_setting.trim_prefix("LP").split("=")[0])
				#print(str(loop))
			stop()
			downloader.download(music_setting, "user://", "bg_music.ogg")
	
	if song != null and stream != song.stream:
		stream = song.stream
		play()
		
		if song.underwater_stream != null:
			water_music_player.stream = song.underwater_stream
			water_music_player.play()
			water_music_player.volume_db = -80
			has_water = true
			play_water = false
		else:
			water_music_player.stop()
			has_water = false
			play_water = false
	
	if "mode" in get_tree().get_current_scene():
		bus = play_bus if get_tree().get_current_scene().mode == 0 else edit_bus
	else:
		bus = play_bus # perhaps we should define a general bus or a menu bus later

func toggle_underwater_music(state):
	if has_water:
		play_water = state
	else:
		play_water = false

func reset_music():
	toggle_underwater_music(false)

func _process(delta) -> void:
	#if Input.is_action_just_pressed("volume_up"):
	#	increment_global_volume(0.1)
	#if Input.is_action_just_pressed("volume_down"):
	#	increment_global_volume(-0.1)
	
	var current_scene = get_tree().get_current_scene()
	var current_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
	
	# change this script so this entire block ceases to exist because it is bad and it makes me simultaniously mad and sad
	# scenes should ask the music singleton to change the music, the music singleton shouldn't check every frame for if it should change the music
	if "mode" in current_scene: #script will crash if the scene root doesn't have this property defined
		var level_song = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music
		if current_scene.mode != last_mode or typeof(last_song) != typeof(level_song):
			change_song(last_song, level_song)
		elif last_song != current_song:
			change_song(last_song, level_song)
		last_mode = current_scene.mode
		last_song = level_song
	
	if play_water and !is_instance_valid(character):
		play_water = false
	
	var target_volume = (db2linear(base_volume) * volume_multiplier) if (!muted and !get_tree().paused) else 0
	volume_db = linear2db(lerp(db2linear(volume_db), target_volume if !play_water else 0, delta * 3))
	water_music_player.volume_db = linear2db(lerp(db2linear(water_music_player.volume_db), target_volume if play_water else 0, delta * 3))
	if temp_music:
		var target_temp_volume = db2linear(base_volume) if (!muted and !get_tree().paused) else 0
		temporary_music_player.volume_db = linear2db(lerp(db2linear(temporary_music_player.volume_db), target_temp_volume, delta * 3))
	else:
		temporary_music_player.volume_db = linear2db(lerp(db2linear(temporary_music_player.volume_db), 0, delta * 3))
		temporary_music_player.volume_db = linear2db(lerp(db2linear(temporary_music_player.volume_db), 0, delta * 3))
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("mute"):
		muted = !muted

# the plan for this is to mute the current bgm, play the temp song, and then fade the current bgm back in
func play_temporary_music(temp_song_id : int = 0, temp_song_volume : float = 0) -> void:
	volume_multiplier = 0
	volume_db = -80.0
	water_music_player.volume_db = -80.0

	#var _tween = tween.stop_all()
	#temporary_music_player.volume_db = temp_song_volume if !muted else -80.0

	var stream = get_song(temp_song_id).stream
	if temporary_music_player.stream != stream or !is_temporary_music_playing():
		temporary_music_player.volume_db = 0
		temporary_music_player.stream = stream
		temporary_music_player.play()
	temp_music = true

# returns the id of the temporary song
func is_temporary_music_playing() -> bool:
	return temp_music

# can be called manually, also automatically called if the temporary music ends
func stop_temporary_music(volume_multiplier_target = 1, music_fade_length = MUSIC_FADE_LENGTH) -> void:
	volume_multiplier = 1
	temp_music = false
