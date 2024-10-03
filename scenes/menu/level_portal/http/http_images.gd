class_name HTTPImages
extends HTTPRequest


signal image_loaded(url, texture)

var image_queue: Array = []
var cached_images: Dictionary = {}
var loading: bool


func clear_queue():
	loading = false
	image_queue.clear()
	cancel_request()
	if is_connected("request_completed", self, "request_completed"):
		disconnect("request_completed", self, "request_completed")


func get_cached_image(url: String) -> ImageTexture:
	return cached_images.get(url)


func load_next_image():
	if image_queue.size() <= 0 or loading: return
	
	var url: String = image_queue.pop_front()
	if get_cached_image(url) == null:
		# let's download it and wait for it to finish before continuing
		# this is a thread and it only downloads once so it's fine to just wait
		#print("Requesting image at url ", url.left(32), "...")
		var error = request(url)
		if error != OK:
			push_error("An error occurred while making an HTTP request.")
		else:
			loading = true
			connect("request_completed", self, "request_completed", [url], CONNECT_ONESHOT)
	
	# just move on if it fails
	if not loading:
		if image_queue.size() > 0:
			call_deferred("load_next_image")


func request_completed(result, response_code, headers, body, url):
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
	
	cached_images[url] = texture
	loading = false
	emit_signal("image_loaded", url, texture)
	
	if image_queue.size() > 0:
		call_deferred("load_next_image")
