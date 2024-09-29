extends HBoxContainer


onready var http_request = $"%HTTPRequest"
onready var query = $Query


func go():
	var text: String = query.text
	query.text = ""
	
	if not text.is_valid_integer(): return
	
	var page: int = int(text)
	http_request.load_page(page)
