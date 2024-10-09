class_name HTTPThumbnails
extends HTTPImages


onready var list_handler = $"%ListHandler"
var ids_queue: Array = []


func clear_queue():
	ids_queue.clear()
	.clear_queue()


func add_to_queue(url: String, level_id: String):
	image_queue.append(url)
	ids_queue.append(level_id)


func load_next_image():
	if image_queue.size() <= 0 or loading: return
	
	var working_folder: String = list_handler.working_folder
	var level_id: String = ids_queue[0]
	
	var thumbnail_path: String = saved_levels_util.get_level_thumbnail_path(level_id, working_folder)
	if not saved_levels_util.file_exists(thumbnail_path):
		.load_next_image()
	else:
		var _id: String = ids_queue.pop_front()
		var url: String = image_queue.pop_front()
		var texture: ImageTexture = saved_levels_util.get_image_from_path(thumbnail_path)
		
		cache_image(url, texture)
		emit_signal("image_loaded", url, texture)
		call_deferred("load_next_image")


func request_completed(result, response_code, headers, body, url):
	.request_completed(result, response_code, headers, body, url)
	
	## we wanna save these as files to cache later :p
	
	var working_folder: String = list_handler.working_folder
	var level_id: String = ids_queue.pop_front()
	
	var path: String = saved_levels_util.get_level_thumbnail_path(level_id, working_folder, false)
	var extension: String = ".png" if image_util.is_png(body) else ".jpg"
	
	var image_file := File.new()
	var err: int = image_file.open(path + extension, File.WRITE)
	if err != OK:
		push_error("Error saving level thumbnail. Error code: " + str(err))
		return
	
	image_file.store_buffer(body)
	image_file.close()
