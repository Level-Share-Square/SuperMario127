extends MarginContainer


onready var area_name_anim = $"%AreaNameAnim"
onready var song_name_anim = $"%SongNameAnim"

onready var area_name = $"%AreaName"
onready var area_name_back_1 = $"%AreaNameBack1"
onready var area_name_back_2 = $"%AreaNameBack2"

onready var song_name = $"%SongName"
onready var author_name = $"%AuthorName"

export var area_start_delay: float
export var song_start_delay: float
export var song_end_delay: float

func _ready():
	yield(owner, "loaded")
	
	var header: AreaHeader = CurrentLevelData.current_area.header
	
	if CurrentLevelData.is_new_area:
		CurrentLevelData.is_new_area = false
		
		if header.name != "" and header.show_name:
			area_name.text = header.name
			area_name_back_1.text = area_name.text
			area_name_back_2.text = area_name.text
			
			var tween: SceneTreeTween = create_tween()
			tween.tween_interval(area_start_delay)
			tween.tween_callback(area_name_anim, "play", ["appear"])
	
	yield(get_tree().create_timer(song_start_delay), "timeout")
	
	if Singleton.Music.song_switched:
		Singleton.Music.song_switched = false
		
		var song_id = header.music
		if song_id is int:
			var song_data: LevelSong = Singleton.Music.get_song(song_id)
			song_name.text = song_data.title
			author_name.text = song_data.note
		else:
			song_name.text = header.custom_music_name
			author_name.text = header.custom_music_author
		
		var tween: SceneTreeTween = create_tween()
		tween.tween_callback(song_name_anim, "play", ["appear"])
		tween.tween_interval(song_end_delay)
		tween.tween_callback(song_name_anim, "play_backwards", ["appear"])
