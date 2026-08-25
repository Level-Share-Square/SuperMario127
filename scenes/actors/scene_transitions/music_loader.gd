extends Node
class_name MusicLoader

var music_urls: Array
var completed_songs: Array
var failed_songs: Array

signal finished_loading

func cache_music() -> void:
	for array in [music_urls, completed_songs, failed_songs]:
		array.clear()
	
	for header in CurrentLevelData.area_headers:
		if header.music is String and header.music and not header.music in music_urls:
			music_urls.append(header.music)
		if header.underwater_music and not header.underwater_music in music_urls:
			music_urls.append(header.underwater_music)
			
	for url in music_urls:
		var song = yield(AssetHandler.load_sound(url, CurrentLevelData.working_folder), "completed")
		
		if not song or not song.data: 
			failed_songs.append(url)
			continue
			
		completed_songs.append(url)
		
	emit_signal("finished_loading")
