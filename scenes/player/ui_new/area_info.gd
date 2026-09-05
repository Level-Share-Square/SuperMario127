extends MarginContainer


onready var area_name_anim = $"%AreaNameAnim"
onready var song_name_anim = $"%SongNameAnim"

onready var area_container = $"%AreaContainer"
onready var song_container = $"%SongContainer"

onready var area_name = $"%AreaName"
onready var area_name_back_1 = $"%AreaNameBack1"
onready var area_name_back_2 = $"%AreaNameBack2"

onready var song_name = $"%SongName"
onready var author_name = $"%AuthorName"

export var area_start_delay: float
export var song_start_delay: float
export var song_end_delay: float

var area_tween: SceneTreeTween
var song_tween: SceneTreeTween

func _ready():
	yield(owner, "loaded")
	
	if CurrentLevelData.is_hub_level() and not CurrentLevelData.shine_kickout_data.empty():
		yield(get_tree().create_timer(6), "timeout")
	
	var header: AreaHeader = CurrentLevelData.current_area.header
	
	if CurrentLevelData.is_new_area:
		CurrentLevelData.is_new_area = false
		
		if header.name != "" and header.show_name:
			area_name.text = header.name
			area_name_back_1.text = area_name.text
			area_name_back_2.text = area_name.text
			
			area_tween = create_tween()
			area_tween.tween_interval(area_start_delay)
			area_tween.tween_callback(area_name_anim, "play", ["appear"])
		else:
			area_name_anim.playback_speed = 0
	
	yield(get_tree().create_timer(song_start_delay), "timeout")
	
	if Singleton.Music.song_switched:
		Singleton.Music.song_switched = false
		
		if header.show_song and not Singleton.ModeSwitcher.visible:
			var song_id = header.music
			if song_id is int:
				var song_data: LevelSong = Singleton.Music.get_song(song_id)
				song_name.text = song_data.title
				author_name.text = song_data.note
			else:
				song_name.text = header.custom_music_name
				author_name.text = header.custom_music_author
			
			song_tween = create_tween()
			song_tween.tween_callback(song_name_anim, "play", ["appear"])
			song_tween.tween_interval(song_end_delay)
			song_tween.tween_callback(song_name_anim, "play_backwards", ["appear"])
		else:
			song_name_anim.playback_speed = 0


func hide_info() -> void:
	if area_container.modulate.a <= 0 and song_container.modulate.a <= 0: return
	if is_instance_valid(area_tween):
		area_tween.kill()
	if is_instance_valid(song_tween):
		song_tween.kill()
	if area_name_anim.playback_speed > 0 and area_name_anim.current_animation != "hide":
		area_name_anim.play("hide")
	if song_name_anim.playback_speed > 0:
		song_name_anim.play_backwards("appear")
