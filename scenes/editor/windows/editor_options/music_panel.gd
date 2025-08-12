extends PanelContainer

enum MUSIC_TYPE {Background, Underwater}

export(MUSIC_TYPE) var music_type

onready var song_url_line = $"%SongURL"
onready var song_name_line = $"%SongName"
onready var loop_start_line = $"%LoopStart"
onready var loop_end_line = $"%LoopEnd"
onready var import = $"%Import"
onready var h_box_container_2 = $VBoxContainer/HBoxContainer2

var loop_start: float
var url: String
var song_name: String = "A song"
var loop_end: float

func _ready():
	if !Singleton.CurrentLevelData.is_campaign:
		import.hide()
	update_panel()
	var lines = [song_url_line, song_name_line, loop_start_line, loop_end_line]
	for line in lines:
		line.connect("text_changed", self, "on_text_changed")

func update_panel():
	var area = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area]
	var raw_music
	if music_type == 0:
		raw_music = area.music
	else:
		raw_music = area.underwater_music
		
	if typeof(raw_music) == TYPE_INT:
		return #regular music implementation
		
	#final music url example: LP0.00={Link}|LEP=0.00N=supermario127song
	var variables: Array = Singleton.Music.decode_new_music(raw_music)
	loop_start = variables[0]
	url = variables[1]
	loop_end = variables[2]
	song_name = variables[3]
	
	loop_start_line.text = str(loop_start)
	song_url_line.text = url
	loop_end_line.text = str(loop_end)
	song_name_line.text = song_name
		

func save_song() -> String:
	var area = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area]
	var encoded_song: String = ""
	encoded_song += "LP%s=%s|LEP=%sN=%s" % [loop_start, url, loop_end, song_name]
	if music_type == 0:
		area.music = encoded_song
	else:
		area.underwater_music = encoded_song
	return encoded_song

func on_text_changed(new_text):
	url = song_url_line.text
	song_name = song_name_line.text
	loop_start = float(loop_start_line.text)
	loop_end = float(loop_end_line.text)
	save_song()
