extends AudioStreamPlayer


const BEAT_MULTIPLE: int = 2

export var bpm: float = 104
onready var seconds_per_beat: float = 60.0 / bpm

var song_position: float
var song_position_in_beats: int
var last_beats: int
 
export var playback_queued: bool

onready var screen: Control = get_owner()
onready var sync_node: AudioStreamPlayer = Singleton.Music


func page_loaded(_page: int, _total_pages: int, _sort_type: int, _last_query: String):
	playback_queued = true


func _process(delta):
	if not is_instance_valid(sync_node): return
	if not sync_node.playing: return
	if int(sync_node.cur_setting) != screen.music_id: return
	
	song_position = sync_node.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position += AudioServer.get_output_latency()
	
	song_position_in_beats = int(floor(song_position / seconds_per_beat))
	if song_position_in_beats != last_beats:
		if song_position_in_beats % BEAT_MULTIPLE == 0 and playback_queued:
			play()
			playback_queued = false
		last_beats = song_position_in_beats
		#print(song_position_in_beats)
