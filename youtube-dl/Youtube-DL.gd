extends Object

class_name YouTubeDl

var current_os = OS.get_name()
var user_directory = OS.get_executable_path().get_base_dir()
var _downloader = Downloader.new()

enum {VIDEO_MP4, VIDEO_WEBM}
enum {AUDIO_AAC, AUDIO_FLAC, AUDIO_MP3, AUDIO_M4A, AUDIO_OPUS, AUDIO_VORBIS, AUDIO_WAV}

signal download_complete
signal ready

var ready = false

func _init():
	_downloader.connect("request_completed", self, "_http_download_complete")

	# Download youtube-dl
	if current_os == "X11" or current_os == "OSX":
		pass
		#_downloader.download("https://yt-dl.org/downloads/latest/youtube-dl", user_directory + "/", "youtube-dl")

	elif current_os == "Windows":
		var file = File.new()
		if file.file_exists(user_directory + "/youtube-dl.exe"):
			_http_download_complete()

func _http_download_complete():
	ready = true
	print("[YouTubeDl]: Ready!")
	emit_signal("ready")

func download(url : String, destination_path : String, filename : String = "", convert_to_audio : bool = false, video_format : int = VIDEO_WEBM, audio_format : int = AUDIO_VORBIS):
	if ready:
		var thread = Thread.new()
		thread.start(self, "_dl_thread", [url, destination_path, filename, convert_to_audio, video_format, audio_format])

func _dl_thread(arguments):
	var url = arguments[0]
	var destination_path = arguments[1]
	var filename = arguments[2]
	var convert_to_audio = arguments[3]
	var video_format = arguments[4]
	var audio_format = arguments[5]

	if filename =="": filename ="%(title)s"
	
	if convert_to_audio == true:
		var format
		match audio_format:
			AUDIO_AAC:format = "aac"
			AUDIO_VORBIS:format = "vorbis"
			AUDIO_FLAC:format = "flac"
			AUDIO_OPUS:format = "opus"
			AUDIO_M4A:format = "m4a"
			AUDIO_MP3:format = "mp3"
			AUDIO_WAV:format = "wav"

		if current_os == "X11" or current_os == "OSX":
			OS.execute(str(user_directory) + "/youtube-dl",  PoolStringArray(["-x", "--audio-format", format, "--no-continue", "-o", destination_path+filename+".%(ext)s", url, "-4", "-q"]), true)
		elif current_os == "Windows":
			var time_start : float = OS.get_ticks_msec()
			OS.execute(str(user_directory) + "/youtube-dl.exe",  PoolStringArray(["-x", "--audio-format", format, "--no-continue", "-o", destination_path+filename+".%(ext)s", url, "-4", "-q"]), true)
			print(str((OS.get_ticks_msec() - time_start) / 1000.0))

	else:
		
		var dir = Directory.new()
		
		var format
		match video_format:
			VIDEO_WEBM:
				format = "bestvideo[ext=webm]+bestaudio"
				dir.remove(destination_path+filename+".webm")
				
			VIDEO_MP4:
				format = "bestvideo[ext=mp4]+m4a"
				dir.remove(destination_path+filename+".mp4")
	
		if current_os == "X11" or current_os == "OSX":
			OS.execute(str(user_directory) + "/youtube-dl",  PoolStringArray(["-f", format, "--no-continue", "-o", destination_path+filename+".%(ext)s",url]), true)
		elif current_os == "Windows":
			OS.execute(str(user_directory) + "/youtube-dl.exe",  PoolStringArray(["-f", format, "--no-continue", "-o", destination_path+filename+".%(ext)s",url]), true)
	
	emit_signal("download_complete")

#func load_ogg():
#	var path = "user://audio.ogg"
#	var ogg_file = File.new()
#	ogg_file.open(path, File.READ)
#	var bytes = ogg_file.get_buffer(ogg_file.get_len())
#	var stream = AudioStreamOGGVorbis.new()
#	stream.data = bytes
#	print(stream.data)
#	if stream.data == null:
#		return
#	ogg_file.close()
#	$AudioStreamPlayer.stream = stream
#	$AudioStreamPlayer.play()
#	print("Audio Loaded!")
#	$UI/DownloadProgress/Label.text="Playing"
