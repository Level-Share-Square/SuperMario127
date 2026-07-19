extends Node

signal file_loaded(err)

var file_extension: String

func load_sound(url: String, working_folder: String):
	var sound_path: String = yield(fetch_asset_path(url, working_folder), "completed")
	
	if !sound_path:
		printerr("Failed to fetch asset path.")
		return null
		
	var file := File.new()
	var err := file.open(sound_path, File.READ)
	
	if err != OK:
		printerr("Failed to open sound", sound_path, " with error code ", err, ".")
		var dir := Directory.new()
		dir.remove(sound_path)
		return null
		
	var bytes: PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	
	match file_extension:
		"ogg":
			var stream := AudioStreamOGGVorbis.new()
			stream.data = bytes
			stream.loop = true
			return stream
		"mp3":
			var stream := AudioStreamMP3.new()
			stream.data = bytes
			stream.loop = true
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
		printerr("Failed to load image from path ", image_path, ". Error code: ", err)
		var dir := Directory.new()
		dir.remove(image_path)
		return null
		
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	return texture

func fetch_asset_path(url: String, working_folder: String) -> String:
	var url_hash: String = url.sha256_text()
	var assets_dir: String = working_folder + "/assets"
	file_extension = url.get_extension()
	var path: String = assets_dir + "/" + url_hash + "." + file_extension
	
	var dir := Directory.new()
	
	if !dir.dir_exists(assets_dir):
		dir.make_dir_recursive(assets_dir)
	
	if dir.file_exists(path):
		yield(get_tree(), "idle_frame") # this function must be a coroutine
		return path
		
	else:
		if !url.begins_with("http"):
			yield(get_tree(), "idle_frame") # this function must be a coroutine
			return ""
		var http_request := HTTPRequest.new()
		add_child(http_request)
		print("Caching new asset: ", url)
		http_request.download_file = path
		http_request.timeout = 10
		http_request.request(url)
		http_request.connect("request_completed", self, "request_completed", [path], CONNECT_ONESHOT)
		
		var response: Array = yield(http_request, "request_completed")
		
		var result = response[0]
		var response_code = response[1]
		var body = response[3]
		
		http_request.queue_free()
		return path if response[1] != ERR_FILE_CANT_OPEN else ""

func request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, file_path: String):
	pass
