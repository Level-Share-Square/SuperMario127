extends Control
class_name MusicLoader

const DEFAULT_LABEL_TEXT: String = "This level contains custom music.\nDo you wish to load it now?\n(This requires an internet connection.)"

onready var choice_container = $"%ChoiceContainer"
onready var label = $"%Label"

var music_urls: Array
var completed_songs: Array
var failed_songs: Array

var is_caching: bool = false

signal finished_loading

func check_cached() -> bool:
	var is_cached: bool = true
	
	for header in CurrentLevelData.area_headers:
		if header.music is String and header.music:
			if not AssetHandler.is_cached(Singleton.Music.decode_music(header.music)[1], CurrentLevelData.working_folder):
				is_cached = false
				break
		if header.underwater_music:
			if not AssetHandler.is_cached(Singleton.Music.decode_music(header.underwater_music)[1], CurrentLevelData.working_folder):
				is_cached = false
				break
				
	return is_cached

func cache_music() -> void:
	choice_container.hide()
	label.text = "Caching..."
	is_caching = true
	
	for array in [music_urls, completed_songs, failed_songs]:
		array.clear()
	
	for header in CurrentLevelData.area_headers:
		if header.music is String and header.music and not header.music in music_urls:
			music_urls.append(Singleton.Music.decode_music(header.music)[1])
		if header.underwater_music and not header.underwater_music in music_urls:
			music_urls.append(Singleton.Music.decode_music(header.underwater_music)[1])
			
	print(music_urls)
			
	for url in music_urls:
		var song = yield(AssetHandler.load_sound(url, CurrentLevelData.working_folder), "completed")
		
		if not song or not song.data: 
			failed_songs.append(url)
			continue
			
		completed_songs.append(url)
		
	emit_signal("finished_loading")
	
	choice_container.show()
	label.text = DEFAULT_LABEL_TEXT
	hide()
	is_caching = false


func skip():
	emit_signal("finished_loading")
	hide()
