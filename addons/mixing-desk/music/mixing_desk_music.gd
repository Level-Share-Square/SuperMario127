extends Node

var tempo
var bars
var beats_in_bar
var transition_beats
var can_shuffle = true

enum play_style {play_once, loop_one, shuffle, endless_shuffle, endless_loop}
export(play_style) var play_mode
export(NodePath) var autoplay

onready var songs = get_children()

const default_vol = 0

var time = 0.0
var beat = 1.0
var last_beat = -1
var suppress_beat = 0.0
var b2bar = 0
var bar = 1.0
var beats_in_sec = 0.0
var can_bar = true
var playing = false
var current_song_num = 0
var current_song
var beat_tran = false
var bar_tran = false
var old_song
var new_song = 0
var repeats = 0

var rollover = null
var rollover_point : int = 0

signal beat
signal bar
signal end
signal shuffle
signal song_changed

func _ready():
	var shuff = Timer.new()
	shuff.name = 'shuffle_timer'
	add_child(shuff)
	shuff.one_shot = true
	var root = Node.new()
	root.name = "root"
	add_child(root)
	var _connect = shuff.connect("timeout", self, "shuffle_songs")
	for song in songs:
		for i in song.get_children():
			if i.cont == "core":
				for o in i.get_children():
					var tween = Tween.new()
					tween.name = 'Tween'
					o.add_child(tween)
	if get_node(autoplay) != self:
		autoplay = str(autoplay)
		if !playing:
			quickplay(autoplay)
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
				
#loads a song and gets ready to play
func init_song(track):
	track = _songname_to_int(track)
	var song = songs[track]
	var root = song._get_core()
	current_song_num = track
	current_song = songs[track]._get_core()
	var _connect = current_song.get_child(0).connect("finished", self, "_core_finished")
	repeats= 0
	for i in root.get_children():
		if song.fading_out:
			i.get_child(0).stop(i)
			song.fading_out = false
		i.set_volume_db(default_vol)
	if song.muted_tracks.size() > 0:
		for i in song.muted_tracks:
			mute(current_song_num, i)
	tempo = song.tempo
	bars = song.bars
	beats_in_bar = song.beats_in_bar
	beats_in_sec = 60000.0/tempo
	transition_beats = (beats_in_sec*song.transition_beats)/1000
	for i in song.get_children():
		if i.cont == "roll":
			rollover = i
			rollover_point = ((song.bars * song.beats_in_bar) - (i.crossover_beat - 1))
			break
		else:
			rollover = null

#updates place in song and detects beats/bars
func _process(delta):
	if suppress_beat > 0:
		suppress_beat -= delta
		return
	if playing:
		time = current_song.get_child(0).get_playback_position()
		beat = int(floor(((time/beats_in_sec) * 1000.0) + 1.0))
		if beat != last_beat and (beat - 1) % int(bars * beats_in_bar) + 1 != last_beat:
			_beat()
		last_beat = beat

#start a song with only one track playing
func start_alone(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	current_song_num = song
	current_song = songs[song]._get_core()
	for i in current_song.get_children():
		i.set_volume_db(-60.0)
	current_song.get_child(layer).set_volume_db(default_vol)
	play(song)

#play in isolation
func _iplay(track):
	var trk = track.duplicate()
	get_node("root").add_child(trk)
	var twe = Tween.new()
	twe.name = "Tween"
	trk.add_child(twe)
	trk.play()
	var _connect = trk.connect("finished", self, "_overlay_finished", [trk])

#kills overlays when finished
func _overlay_finished(trk):
	trk.queue_free()

#fade out overlays
func _stop_overlays():
	for i in get_node("root").get_children():
		i.get_node("Tween").interpolate_property(i, "volume_db", i.volume_db, -60, transition_beats, Tween.TRANS_LINEAR, Tween.EASE_IN)
		i.get_node("Tween").start()
		var _connect = i.get_node("Tween").connect("tween_completed", self, "_overlay_faded", [i])

#delete overlay on fade
func _overlay_faded(object, key, overlay):
	overlay.queue_free()
		
#initialise and play the song immediately
func quickplay(song):
	init_song(song)
	play(song)

#check if ref is string or int
func _songname_to_int(ref):
	if typeof(ref) == TYPE_STRING:		return get_node(ref).get_index()
	else:
		return ref

func _trackname_to_int(song, ref):
	if typeof(ref) == TYPE_STRING:
		return songs[song]._get_core().get_node(ref).get_index()
	else:
		return ref
	
#play a song
func play(song):
	song = _songname_to_int(song)
	time = 0
	bar = 1
	beat = 1
	last_beat = -1
	suppress_beat = beats_in_sec / 1000.0 * 0.5
	if !playing:
		last_beat = 1
		emit_signal("bar", bar)
		_beat()
		playing = true
	for i in songs[song].get_children():
		if i.cont == "core":
			for o in i.get_children():
				o.play()
	_play_overlays(song)

func _play_overlays(song):
	for i in songs[song].get_children():
		if i.cont == "ran":
			randomize()
			var rantrk = _get_rantrk(i)
			if rand_range(0,1) <= i.random_chance:
				_iplay(rantrk)
		if i.cont == "seq":
			var seqtrk = repeats
			if repeats == i.get_child_count():
				seqtrk = 0
				repeats = 0
			_iplay(.get_child(seqtrk))
		if i.cont == "concat":
			if repeats < 1:
				_play_concat(i)
			songs[song].concats.append(i)
		if i.cont == "autofade":
			match i.play_style:
				0:
					var chance = i.get_child_count()
					i.get_child(chance).play()
				1:
					for o in i.get_children():
						o.play()
		if i.cont == "autolayer":
			for o in i.get_children():
				o.play()
	
	if bar_tran:
		bar_tran = false
	if beat_tran:
		beat_tran = false

#play short random tracks in sequence in 'song'
func _play_concat(concat):
	var rantrk = _get_rantrk(concat)
	rantrk.play()
	var _connect = rantrk.connect("finished", self, "concat_fin", [concat])

func _concat_fin(concat):
	for i in concat.get_children():
		if i.is_connected("finished", self, "concat_fin") :
			i.disconnect("finished", self, "concat_fin")
	_play_concat(concat)

#mute all layers above specified layer, and fade in all below
func fadeout_above_layer(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	if songs[song]._get_core().get_child_count() < 2:
		return
	for i in range(0, layer + 1):
		fade_in(song, i)
	for i in range(layer + 1, songs[song]._get_core().get_child_count()):
		fade_out(song, i)

#mute all layers below specified layer, and fade in all below
#use mute_below_layer(0) to fade all tracks in
func fadeout_below_layer(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	for i in range(layer, songs[song]._get_core().get_child_count()):
		fade_in(song, i)
	if layer > 0:
		for i in range(0, layer - 1):
			fade_out(song, i)
		if layer == 1:
			fade_out(song, 0)
			
#mute all layers aside from specified layer
func solo(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	for i in range(layer + 1, songs[song]._get_core().get_child_count()):
		fade_out(song, i)
	if layer > 0:
		for i in range(0, layer - 1):
			fade_out(song, i)
		if layer == 1:
			fade_out(song, 0)

#mute only the specified layer
func mute(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	target.set_volume_db(-60.0)
	var pos = songs[song].muted_tracks.find(layer)
	if pos == null:
		songs[song].muted_tracks.append(layer)

#unmute only the specified layer
func unmute(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	target.set_volume_db(default_vol)
	var pos = songs[song].muted_tracks.find(layer)
	if pos != -1:
		songs[song].muted_tracks.remove(pos)

#mutes a track if not mutes, or vice versa
func toggle_mute(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	if target.volume_db < 0:
		unmute(song, layer)
	else:
		mute(song, layer)

#slowly bring in the specified layer
func fade_in(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	var tween = target.get_node("Tween")
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, default_vol, transition_beats, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	var pos = songs[song].muted_tracks.find(layer)
	if pos != -1:
		songs[song].muted_tracks.remove(pos)

#slowly take out the specified layer
func fade_out(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	var tween = target.get_node("Tween")
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, -60.0, transition_beats, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

#fades a track in if silent, fades out if not
func toggle_fade(song, layer):
	song = _songname_to_int(song)
	layer = _trackname_to_int(song, layer)
	var target = songs[song]._get_core().get_child(layer)
	if target.volume_db < 0:
		fade_in(song, layer)
	else:
		fade_out(song, layer)

#change to the specified song at the next bar
func queue_bar_transition(song):
	song = _songname_to_int(song)
	old_song = current_song_num
	songs[old_song].fading_out = true
	new_song = song
	bar_tran = true
	
#change to the specified song at the next beat
func queue_beat_transition(song):
	song = _songname_to_int(song)
	old_song = current_song_num
	songs[old_song].fading_out = true
	new_song = song
	beat_tran = true

#play two tracks in order, either ending, looping or shuffling on the second
func queue_sequence(sequence : Array, type : String, on_end : String):
	match type:
		"beat":
			queue_beat_transition(sequence[0])
		"bar":
			queue_bar_transition(sequence[0])
	play_mode = 0
	yield(self,"song_changed")
	yield(self,"end")
	init_song(sequence[1])
	play(sequence[1])
	match on_end:
		"play_once":
			play_mode = 0
		"loop":
			play_mode = 1
		"shuffle":
			play_mode = 2
		"endless":
			play_mode = 3

#unload and stops the current song, then initialises and plays the new one
func _change_song(song):
	old_song = current_song_num
	song = _songname_to_int(song)
	current_song.get_child(0).disconnect("finished", self, "_core_finished")
	if song != current_song_num:
		emit_signal("song_changed", [old_song, song])
		init_song(song)
		for i in songs[old_song].get_children():
			if i.cont == "core":
				if songs[old_song].transition_beats >= 1:
					for o in i.get_child_count():
						fade_out(old_song, o)
			elif i.cont != "rollover":
				for o in i.get_children():
					if o.playing:
						o.stop()
	_stop_overlays()
	play(song)

#stops playing
func stop(song):
	song = _songname_to_int(song)
	current_song.get_child(0).disconnect("finished", self, "_core_finished")
	if playing:
		playing = false
		for i in songs[song]._get_core().get_children():
			i.stop()
			i.stream.loop = false
		_stop_overlays()

#when the core loop finishes its loop
func _core_finished():
	songs[current_song_num].concats.clear()
	emit_signal("end", current_song_num)
	match play_mode:
		1:
			bar = 1
			beat = 1
			last_beat = -1
			repeats += 1
			play(current_song_num)
		2:
			$shuffle_timer.start(rand_range(2,4))
		3:
			shuffle_songs()
		4:
			var new_song
			if current_song_num == (get_child_count() - 3):
				new_song = 0
			else:
				new_song = current_song_num + 1
			_change_song(new_song)

#called every bar
func _bar():
	if can_bar:
		can_bar = false
		if bar_tran:
			if current_song_num != new_song:
				_change_song(new_song)
			else:
				play(new_song)
		yield(get_tree().create_timer(0.5), "timeout")
		can_bar = true
	
#called every beat
func _beat():
	if beat_tran:
		if current_song_num != new_song:
			_change_song(new_song)
		else:
			play(new_song)
	if b2bar == beats_in_bar:
		b2bar = 1
		bar += 1
		_bar()
		emit_signal("bar", bar)
	else:
		b2bar += 1
	if rollover != null:
		if beat == rollover_point:
			if rollover.get_child_count() > 1:
				var roll = rollover.get_child(randi() % rollover.get_child_count())
				roll.play()
			else:
				rollover.get_child(0).play()
	emit_signal("beat", (beat - 1) % int(bars * beats_in_bar) + 1)

#gets a random track from a song and returns it
func _get_rantrk(song):
	song = _songname_to_int(song)
	var chance = randi() % song.get_child_count()
	var rantrk = song.get_child(chance)
	return rantrk

#choose new song randomly
func shuffle_songs():
	randomize()
	var song = randi() % (songs.size())
	if song == current_song_num:
		if song == 0:
			song += 1
		elif song == songs.size() - 1:
			song -= 1
	emit_signal("shuffle", [current_song_num, song])
	new_song = song
	_change_song(song)
