extends HBoxContainer


onready var http_request = $"%HTTPRequest"
onready var query = $Query

onready var default = $Default
onready var featured = $Featured
onready var favorited = $Favorites/Favorited


onready var sort_nodes: Array = [
	$Padding,
	$Default,
	$Divider,
	$Featured,
	$Favorites/Divider,
	$Favorites/Favorited
]

onready var search_nodes: Array = [
	$Query,
	$Search
]


func search():
	http_request.load_page(http_request.page, http_request.sort_type, query.text)


func screen_opened():
	query.text = http_request.last_query


func page_loaded(_page: int, _total_pages: int, sort_type: int, last_query: String):
	default.pressed = false
	featured.pressed = false
	favorited.pressed = false
	
	match (sort_type):
		http_request.SortType.Default:
			default.pressed = true
		http_request.SortType.Featured:
			featured.pressed = true
		http_request.SortType.Favorited:
			favorited.pressed = true
	
	
	for search_node in search_nodes:
		search_node.visible = (sort_type == http_request.SortType.Default)
	
	for sort_node in sort_nodes:
		sort_node.visible = (last_query == "")
