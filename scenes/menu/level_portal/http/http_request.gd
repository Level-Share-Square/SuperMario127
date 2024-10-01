extends HTTPRequest


onready var level_grid = $"%LevelGrid"
onready var pages = $"%Pages"
onready var loading = $"%Loading"
onready var search = $"%Search"

onready var http_images = $"%HTTPImages"

var page: int = -1
var total_pages: int = 99

var is_featured: bool
var last_query: String


## for connecting signals easier
func change_page_type(featured: bool):
	if last_query != "": return
	load_page(page, featured)


func load_page(new_page: int = page, featured: bool = is_featured, query = last_query):
	if featured == is_featured:
		new_page = clamp(new_page, 1, total_pages)
		
		if query != last_query:
			last_query = query
			new_page = 1
		else:
			if new_page == page: return
	else:
		is_featured = featured
		new_page = 1

	
	level_grid.clear_children()
	http_images.clear_queue()
	
	page = new_page
	pages.visible = false
	search.visible = false
	loading.visible = true
	
	
	print("Requesting online levels... (Page: ", str(new_page), ")")
	
	
	var search: String
	if query != "":
		search = "&name=" + query
		is_featured = false
	
	var sort_type: String = "featured" if is_featured else "filter"
	
	var error: int = request("https://levelsharesquare.com/api/levels/" + sort_type + "/get?page=" + str(page) + "&game=2&authors=true" + search)
	if error != OK:
		push_error("An error occurred while making an HTTP request.")


func request_completed(result, response_code, headers, body):
	if response_code != 200 and response_code != 400: 
		push_error("Failed to connect to Level Share Square. Response code: " + str(response_code))
		return
	
	if response_code != 400:
		var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
		
		for level_dict in json.result.levels:
			var level_info := LSSLevelInfo.new(level_dict)
			var thumbnail: ImageTexture = http_images.get_cached_image(level_info.thumbnail_url)
			if thumbnail == null and level_info.thumbnail_url != "":
				http_images.image_queue.append(level_info.thumbnail_url)
			
			level_grid.add_level(level_info, thumbnail)
		
		total_pages = json.result.get("numberOfPages", 1)
	else:
		page = 1
		total_pages = 1
	
	pages.load_page_buttons(page, total_pages)
	pages.visible = true
	search.visible = true
	loading.visible = false
	
	print("Online levels loaded.")
	http_images.load_next_image()
