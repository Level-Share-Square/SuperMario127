extends Node

const PNG_HEADER := PoolByteArray([0x89, 0x50, 0x4e, 0x47])
const JPEG_HEADER := PoolByteArray([0xff, 0xd8, 0xff])
const OGG_HEADER := PoolByteArray([0x4f, 0x67, 0x67, 0x53])

const WAV_HEADER_FORMER := PoolByteArray([0x52, 0x49, 0x46, 0x46])
const WAV_HEADER_LATTER := PoolByteArray([0x57, 0x41, 0x56, 0x45])

enum ValidImageTypes {PNG, JPEG}
enum ValidSoundTypes {OGG, WAD, MP3}

signal file_loaded(err)

func is_cached(url: String, working_folder: String):
	var url_hash: String = url.md5_text()
	var assets_dir: String = working_folder + "/assets"
	var path: String = assets_dir + "/" + url_hash + "." + url.get_extension() if url.get_extension() else assets_dir + "/" + url_hash
	
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
	
	if not url.get_extension():
		match get_sound_ext_from_bytes(bytes):
			ValidSoundTypes.OGG:
				var stream := AudioStreamOGGVorbis.new()
				stream.data = bytes
				stream.loop = true
				return stream
			ValidSoundTypes.MP3:
				var stream := AudioStreamMP3.new()
				stream.data = bytes
				stream.loop = true
				return stream
			ValidSoundTypes.WAV:
				var stream := AudioStreamSample.new()
				stream.data = bytes
				stream.loop = true
				return stream
			_:
				printerr("Invalid bytes at path ", sound_path)
				return null
	
	
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
		"wav":
			var stream := AudioStreamSample.new()
			stream.data = bytes
			stream.loop = true
			return stream
		_:
			printerr("Invalid file extension at path ", sound_path)
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
	
	if not url.get_extension():
		var file := File.new()
		file.open(image_path, File.READ)
		var bytes = file.get_buffer(file.get_len())
		
		var err
		
		match get_image_ext_from_bytes(bytes):
			ValidImageTypes.PNG:
				err = image.load_png_from_buffer(bytes)
			ValidImageTypes.JPEG:
				err = image.load_jpg_from_buffer(bytes)
			_:
				printerr("Invalid bytes at path ", image_path, ". Error code: ", err)
				return null
		
		if err != OK:
			printerr("Failed to load image directly from bytes from path ", image_path, ". Error code: ", err)
			return null
			
		var texture := ImageTexture.new()
		texture.create_from_image(image)
		return texture
	
	var err := image.load(image_path)
	
	if err != OK:
		printerr("Failed to load image from path ", image_path, ". Error code: ", err)
		return null
		
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	return texture

func fetch_asset_path(url: String, working_folder: String) -> String:
	var url_hash: String = url.md5_text()
	var assets_dir: String = working_folder + "/assets"
	var path: String = assets_dir + "/" + url_hash + "." + url.get_extension() if url.get_extension() else assets_dir + "/" + url_hash
	
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

func get_image_ext_from_bytes(bytes: PoolByteArray) -> int:
	if bytes.size() < 4:
		return -1
		
	var header = bytes.subarray(0, 3)
	
	if header == PNG_HEADER:
		return ValidImageTypes.PNG
		
	if bytes.subarray(0, 2) == JPEG_HEADER:
		return ValidImageTypes.JPEG
		
	return -1
	
func get_sound_ext_from_bytes(bytes: PoolByteArray) -> int:
	if bytes.size() < 4:
		return -1
		
	var header_former = bytes.subarray(0, 3)
	
	if header_former == OGG_HEADER:
		return ValidSoundTypes.OGG
		
	if bytes.size() >= 12:
		var header_latter = bytes.subarray(8, 11)
		if header_former == WAV_HEADER_FORMER and header_latter == WAV_HEADER_LATTER:
			return ValidSoundTypes.WAV
			
	return ValidSoundTypes.MP3
	
