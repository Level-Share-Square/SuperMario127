extends Node

enum AudioType {OGG, MP3}

signal file_loaded(err)

func load_sound(url: String, working_folder: String):
	var sound_path: String = yield(fetch_asset_path(url, working_folder), "completed")
	
	if sound_path == null:
		printerr("Failed to fetch asset path.")
		return null
		
	var file := File.new()
	var err := file.open(sound_path, File.READ)
	
	if err != OK:
		printerr("Failed to open sound.")
		return null
		
	var bytes: PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	
	var file_type: int = check_audio_type(bytes)
	
	match file_type:
		AudioType.OGG:
			var stream := AudioStreamOGGVorbis.new()
			stream.data = bytes
			return stream
		AudioType.MP3:
			var stream := AudioStreamMP3.new()
			stream.data = bytes
			return stream
		_:
			return null
	
	

func load_image(url: String, working_folder: String) -> ImageTexture:
	var image_path: String = yield(fetch_asset_path(url, working_folder), "completed")
	
	if image_path == null:
		printerr("Failed to fetch asset path.")
		return null
		
	var image := Image.new()
	var err := image.load(image_path)
	
	if err != OK:
		printerr("Failed to load image from path", image_path, ". Error code: ", err)
		return null
		
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	return texture

func fetch_asset_path(url: String, working_folder: String) -> String:
	var url_hash: String = str(hash(url))
	var assets_dir: String = working_folder + "/assets"
	var path: String = assets_dir + "/" + url_hash
	
	var dir := Directory.new()
	
	if !dir.dir_exists(assets_dir):
		dir.make_dir_recursive(assets_dir)
	
	if dir.file_exists(path):
		yield(get_tree(), "idle_frame") # this function must be a coroutine
		return path
		
	else:
		var http_request := HTTPRequest.new()
		add_child(http_request)
		
		http_request.request(url)
		http_request.connect("request_completed", self, "request_completed", [path], CONNECT_ONESHOT)
		
		var err = yield(self, "file_loaded")
		http_request.queue_free()
		return path if err == OK else null

func request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, file_path: String):
	var file := File.new()
	var err: int = file.open(file_path, File.WRITE)
	if err != OK:
		printerr("Error saving file. Error code: " + str(err) + "\nFile path: " + file_path)
		emit_signal("file_loaded", err)
		return
	
	file.store_buffer(body)
	file.close()
	emit_signal("file_loaded", OK)

func check_audio_type(bytes: PoolByteArray) -> int:
	if bytes.size() < 4:
		printerr("File too small to be valid audio.")
		return -1
		
	# OGGs byte signature
	if bytes[0] == 0x4F and bytes[1] == 0x67 and bytes[2] == 0x67 and bytes[3] == 0x53:
		return AudioType.OGG
		
	#ID3v2 byte signature
	elif bytes[0] == 0x49 and bytes[1] == 0x44 and bytes[2] == 0x33:
		return AudioType.MP3
		
	else:
		printerr("Unknown audio file.")
		return -1
