extends HTTPRequest


signal thumbnail_loaded(level_id)

# thumbnail queue goes like
# [url, level_id]
# so that the script can check if it exists first
# as well as include the id in the signal
var thumbnail_queue: Array = []
var cached_thumbnails: Dictionary = {}


func clear_queue():
	thumbnail_queue.clear()
	if is_connected("request_completed", self, "request_completed"):
		disconnect("request_completed", self, "request_completed")


func get_cached_thumbnail(level_id: String) -> ImageTexture:
	return cached_thumbnails.get(level_id)


func load_next_thumb():
	if thumbnail_queue.size() <= 0: return
	
	var thumbnail = thumbnail_queue.pop_front()
	var url: String = thumbnail[0]
	var level_id: String = thumbnail[1]
	
	if get_cached_thumbnail(level_id) == null:
		# let's download it and wait for it to finish before continuing
		# this is a thread and it only downloads once so it's fine to just wait
		var error = request(url)
		if error != OK:
			push_error("An error occurred while making an HTTP request.")
		else:
			connect("request_completed", self, "request_completed", [level_id], CONNECT_ONESHOT)


func request_completed(result, response_code, headers, body, level_id):
	var image := Image.new()
	
	var error: int = -1
	if image_util.is_png(body):
		error = image.load_png_from_buffer(body)
	else:
		error = image.load_jpg_from_buffer(body)
	
	if error != OK:
		push_error("Image failed to load.")
	
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	
	cached_thumbnails[level_id] = texture
	emit_signal("thumbnail_loaded", level_id, texture)

	if thumbnail_queue.size() > 0:
		call_deferred("load_next_thumb")
