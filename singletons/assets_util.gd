extends Node

signal file_loaded(err)

func is_cached(url: String, working_folder: String):
	var url_hash: String = url.md5_text()
	var assets_dir: String = working_folder + "/assets"
	var path: String = assets_dir + "/" + url_hash + "." + url.get_extension()
	
	var dir := Directory.new()
	
	return dir.dir_exists(path)
		
		
func load_sound(url: String, working_folder: String):
	var sound_path: String = yield(fetch_asset_path(url, working_folder), "completed")
	
	if sound_path.empty():
		printerr("Failed to fetch asset path.")
		return null
		
	var file := File.new()
	var err := file.open(sound_path, File.READ)
	
	if err != OK:
		printerr("Failed to open sound", sound_path, " with error code ", err, ".")
		return null
		
	var bytes: PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	
	var file_extension: String = url.get_extension()
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
	
	

func load_image(url: String, working_folder: String, id: String = "") -> ImageTexture:
	var old_level_thumbnail: String = level_list_util.get_level_thumbnail_path(id, working_folder)
	if level_list_util.file_exists(old_level_thumbnail):
		yield(get_tree(), "idle_frame")
		return level_list_util.get_image_from_path(old_level_thumbnail)

	var image_path: String = yield(fetch_asset_path(url, working_folder), "completed")
	
	if image_path.empty():
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
	var url_hash: String = url.md5_text()
	var assets_dir: String = working_folder + "/assets"
	var path: String = assets_dir + "/" + url_hash + "." + url.get_extension()
	
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

		var response: Array = yield(http_request, "request_completed")
		
		var result: int = response[0]
		var response_code: int = response[1]

		if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
			return path
		else:
			printerr("HTTP Request failed for ", url, " Result: ", result, " Code: ", response_code)
			if dir.file_exists(path):
				dir.remove(path)
			return ""
