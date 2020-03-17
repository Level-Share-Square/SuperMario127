extends AudioStreamPlayer

export var play_bus: String
export var edit_bus: String

export var volume_multiplier = 1
var orig_volume = 1

var last_mode = 3

func get_song(song_id: int):
	var level_songs : IdMap  = preload("res://assets/music/ids.tres")
	var song : LevelSong = load("res://assets/music/resources/" + level_songs.ids[song_id] + ".tres")
	return song

func _ready():
	orig_volume = volume_db

func _process(delta):
	if get_tree().get_current_scene().mode != last_mode:
		var song = get_song(CurrentLevelData.level_data.areas[0].settings.music)
		if stream != song.stream:
			stream = song.stream
			play()
		if get_tree().get_current_scene().mode == 0:
			bus = play_bus
		else:
			bus = edit_bus
	volume_db = orig_volume * volume_multiplier
	last_mode = get_tree().get_current_scene().mode

func _input(event):
	if event.is_action_pressed("mute"):
		volume_multiplier = 10 if volume_multiplier == 1 else 1
