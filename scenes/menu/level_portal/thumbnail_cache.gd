extends Node

signal thumbnail_loaded(level_id)

onready var list_handler: Node = get_parent()
onready var thread := Thread.new()

# thumbnail queue goes like
# [url, level_id]
# so that the script can check if it exists first
# as well as include the id in the signal
var thumbnail_queue: Array = []
var cached_thumbnails: Dictionary = {}

func clear_queue():
	thumbnail_queue.clear()

func go_through_queue():
	if thread.is_active():
		thread.wait_to_finish()
	thread.start(self, "queue_thread")

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if thread.is_active():
		thread.wait_to_finish()


func queue_thread():
	var downloader := ThumbnailDownloader.new()
	var working_folder: String = list_handler.working_folder
	
	for thumbnail in thumbnail_queue:
		var url: String = thumbnail[0]
		var level_id: String = thumbnail[1]
		
		var thumbnail_path: String = level_list_util.get_level_thumbnail_path(level_id, working_folder)
		if not level_id in cached_thumbnails.keys():
			# let's download it and wait for it to finish before continuing
			# this is a thread and it only downloads once so it's fine to just wait
			downloader.download(url, working_folder + "/thumbnails/", level_id)
			thumbnail_path = level_list_util.get_level_thumbnail_path(level_id, working_folder)
		
		var image: ImageTexture = level_list_util.get_image_from_path(thumbnail_path)
		cached_thumbnails[level_id] = image
		emit_signal("thumbnail_loaded", level_id)
