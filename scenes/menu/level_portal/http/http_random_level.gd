extends HTTPRequest


onready var subscreens = $"../Subscreens"

onready var http_level_page = $"%HTTPLevelPage"
onready var http_images = $"%HTTPImages"


func load_random_level():
	if is_instance_valid(subscreens.current_screen):
		subscreens.current_screen.transition("")
	
	http_images.clear_queue()
	
	print("Requesting a random level...")
	var error: int = request("https://levelsharesquare.com/api/levels/filter/get?&game=2&count=1&random=true")
	if error != OK:
		push_error("An error occurred while making an HTTP request.")


func request_completed(result, response_code, headers, body):
	if response_code != 200: 
		push_error("Failed to connect to Level Share Square. Response code: " + str(response_code))
		return
	
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	var level_dict: Dictionary = json.result.levels[0]
	
	http_level_page.load_level(level_dict._id)
	print("Random level id found. ID: " + level_dict._id)
