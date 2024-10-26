extends HTTPRequest


signal page_loaded(page, total_pages, sort_type, last_query)
enum SortType {Default, Featured, Favorited}

onready var level_grid = $"%LevelGrid"
onready var pages = $"%Pages"
onready var loading = $"%Loading"
onready var search = $"%Search"

onready var account_info = $"%AccountInfo"
onready var http_images = $"%HTTPImages"

var page: int = -1
var total_pages: int = 99

var sort_type: int
var last_query: String

var return_args: PoolStringArray = [
	"page",
	"total_pages",
	"sort_type",
	"last_query"
]


## for connecting signals easier
func change_page_type(sort_type: int):
	if last_query != "": return
	load_page(page, sort_type)


func load_page(new_page: int = page, new_sort: int = SortType.Default, query = last_query):
	if not account_info.logged_in and new_sort == SortType.Favorited:
		new_sort = SortType.Default
	
	if sort_type == new_sort:
		new_page = clamp(new_page, 1, total_pages)
		
		if query != last_query:
			last_query = query
			new_page = 1
	else:
		sort_type = new_sort
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
		sort_type = SortType.Default
	
	var filter: String = "filter" 
	if sort_type == SortType.Featured:
		filter = "featured"
	elif sort_type == SortType.Favorited:
		filter = "favourites/" + account_info.id
	
	
	var header: PoolStringArray
	if account_info.logged_in:
		# without the wait time i get errors...
		yield(get_tree().create_timer(0.1), "timeout")
		header.append("Authorization: Bearer " + account_info.token)
	
	var error: int = request(
		("https://levelsharesquare.com/api/levels/" 
		+ filter 
		+ "/get?page=" 
		+ str(page) 
		+ "&game=2&authors=true" 
		+ search
	), header)
	if error != OK:
		printerr("An error occurred while making an HTTP request.")


func request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	if response_code != 200 and response_code != 400: 
		printerr("Failed to connect to Level Share Square. Response code: " + str(response_code))
		return
	
	if response_code == 200:
		var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
		
		for level_dict in json.result.levels:
			var account_id: String = account_info.id if account_info.logged_in else ""
			var level_info := LSSLevelInfo.new(level_dict, account_id)
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
	
	emit_signal("page_loaded", page, total_pages, sort_type, last_query)
	print("Online levels loaded.")
	http_images.load_next_image()
