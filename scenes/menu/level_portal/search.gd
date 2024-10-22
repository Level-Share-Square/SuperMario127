extends HBoxContainer


onready var http_request = $"%HTTPRequest"
onready var query = $Query


onready var default = $Default
onready var featured = $Featured

onready var sort_nodes: Array = [
	$Padding,
	$Default,
	$Divider,
	$Featured,
	$Divider2
]

onready var search_nodes: Array = [
	$Query,
	$Search
]


func search():
	http_request.load_page(http_request.page, http_request.is_featured, query.text)


func screen_opened():
	query.text = http_request.last_query


func page_loaded(_page: int, _total_pages: int, is_featured: bool, last_query: String):
	default.pressed = not is_featured
	featured.pressed = is_featured
	
	for search_node in search_nodes:
		search_node.visible = not is_featured
	
	for sort_node in sort_nodes:
		sort_node.visible = (last_query == "")
