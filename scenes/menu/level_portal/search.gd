extends HBoxContainer


onready var http_request = $"%HTTPRequest"
onready var query = $Query


func search():
	http_request.load_page(http_request.page, http_request.is_featured, query.text)
