extends HTTPRequest


onready var level_grid = $"%LevelGrid"
onready var pages = $"%Pages"
onready var loading = $"%Loading"
onready var http_thumbnails = $"%HTTPThumbnails"

var page: int = -1
var total_pages: int = 99


func load_page(new_page: int = page):
	new_page = clamp(new_page, 1, total_pages)
	if new_page == page: return
	
	page = new_page
	pages.visible = false
	
	level_grid.clear_children()
	http_thumbnails.clear_queue()
	
	loading.visible = true
	
	print("Requesting online levels... (Page: ", str(new_page), ")")
	var error: int = request("https://levelsharesquare.com/api/levels/filter/get?page=" + str(page) + "&game=2&authors=true")
	if error != OK:
		push_error("An error occurred while making an HTTP request.")


func request_completed(result, response_code, headers, body):
	if response_code != 200: 
		push_error("Failed to connect to Level Share Square. Response code: " + str(response_code))
		return
		
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	for level_dict in json.result.levels:
		var level_info := LSSLevelInfo.new(level_dict)
		var thumbnail: ImageTexture = http_thumbnails.get_cached_thumbnail(level_info.level_id)
		if thumbnail == null and level_info.thumbnail_url != "":
			http_thumbnails.thumbnail_queue.append([
				level_info.thumbnail_url,
				level_info.level_id
			])
		
		level_grid.add_level(level_info, thumbnail)
	
	loading.visible = false
	
	total_pages = json.result.numberOfPages
	pages.load_page_buttons(page, total_pages)
	pages.visible = true
	
	print("Online levels loaded.")
	http_thumbnails.load_next_thumb()
