extends HTTPRequest


onready var subscreens = $"../Subscreens"
onready var level_panel = $"%LevelPanel"
onready var http_comments = $"%HTTPComments"

var level_id: String


func load_level(_level_id: String):
	level_id = _level_id
	
	print("Requesting level id ", level_id, "...")
	var error: int = request("https://levelsharesquare.com/api/levels/" + level_id + "?keep=true")
	if error != OK:
		push_error("An error occurred while making an HTTP request.")


func request_completed(result, response_code, headers, body):
	if response_code != 200: 
		push_error("Failed to connect to Level Share Square. Response code: " + str(response_code))
		return
	
	var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	var page_info := LSSLevelPage.new(json.result.level)
	level_panel.load_level(page_info)
	
	if is_instance_valid(subscreens.current_screen):
		# otherwise it may stay blank forever...
		var animation_player: AnimationPlayer = subscreens.current_screen.animation_player
		animation_player.disconnect("animation_finished", subscreens.current_screen, "animation_finished")
	
	subscreens.screen_change("LevelPage")
	print("Level page loaded.")
	
	http_comments.load_comments(level_id)
