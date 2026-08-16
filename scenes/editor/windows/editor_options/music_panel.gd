extends PanelContainer

enum MUSIC_TYPE {Background, Underwater}

export(MUSIC_TYPE) var music_type

onready var song_url_line = $"%SongURL"
onready var song_name_line = $"%SongName"
onready var song_author_line = $"%SongAuthor"
onready var info_separator = $"%InfoSeparator"
onready var loop_start_line = $"%LoopStart"
onready var loop_end_line = $"%LoopEnd"
onready var import = $"%Import"
onready var h_box_container_2 = $VBoxContainer/HBoxContainer2

var loop_start: float
var url: String
var song_name: String = "A song"
var loop_end: float

func _ready():
	if !CurrentLevelData.is_campaign:
		import.hide()
	update_panel()
	var lines = [song_url_line, song_name_line, song_author_line, loop_start_line, loop_end_line]
	for line in lines:
		line.connect("text_changed", self, "on_text_changed")

func update_panel():
	var area = CurrentLevelData.current_area
	var raw_music
	if music_type == 0:
		raw_music = area.header.music
	else:
		song_name_line.hide()
		song_author_line.hide()
		info_separator.hide()
		raw_music = area.header.underwater_music
		
	if !raw_music is String:
		return #regular music implementation
		
	#final music url example: LP0.00={Link}|LEP=0.00N=supermario127song
	var variables: Array = Singleton.Music.decode_music(raw_music)
	loop_start = variables[0]
	url = variables[1]
	loop_end = variables[2]
	
	loop_start_line.text = str(loop_start)
	song_url_line.text = url
	loop_end_line.text = str(loop_end)
	song_name_line.text = area.header.custom_music_name
	song_name_line.text = area.header.custom_music_author


func save_song() -> String:
	var area = CurrentLevelData.current_area
	var encoded_song: String = ""
	encoded_song += "LP%s=%s|LEP=%s" % [loop_start, url, loop_end]
	if music_type == 0:
		area.header.music = encoded_song
		area.header.custom_music_name = song_name_line.text.strip_edges().strip_escapes()
		area.header.custom_music_author = song_author_line.text.strip_edges().strip_escapes()
	else:
		area.header.underwater_music = encoded_song
		
	
	return encoded_song

func on_text_changed(new_text):
	url = song_url_line.text
	song_name = song_name_line.text
	loop_start = float(loop_start_line.text)
	loop_end = float(loop_end_line.text)
	save_song()
