extends Screen

var page = 1
var total_pages = 333
var level_codes = []
var actual_codes = []
var level_ids = []
var level_ratings = []
var creators = []
var search_cooldown = 5
var searching = false

var levels = Singleton.SavedLevels.levels

onready var rating = $Control2/Rating
onready var loading = $Loading
onready var buttonx = $Control/VBoxContainer/PanelContainer/buttonX
onready var level_name_label = $Control2/LevelInfo/LevelName
onready var back_button = $Control/HBoxContainer/ButtonBack
onready var add_button = $Control/HBoxContainer/ButtonAdd
onready var copy_button = $Control/HBoxContainer/ButtonCopyCode
onready var level_creator = $Control2/LevelCreator
onready var level_sky_thumbnail = $Control2/LevelInfo/LevelThumbnail/PanelContainer/ThumbnailImage
onready var level_foreground_thumbnail = $Control2/LevelInfo/LevelThumbnail/PanelContainer/ForegroundThumbnailImage
onready var info = $Control2
onready var search = $Control/VBoxContainer/PanelContainer/TextEdit
onready var page_label = $Control/PageSelect/Label
onready var page_right = $Control/PageSelect/Right
onready var page_left = $Control/PageSelect/Left
onready var level_list = $Control/VBoxContainer/LevelListPanel/VBoxContainer/LevelList
onready var http = $HTTPRequest
onready var http2 = $HTTPRequest2
onready var http3 = $HTTPRequest3
onready var comments = $Comments
onready var page_amt = 10
onready var comment_button = $Control2/ButtonComm
# var a = 2
# var b = "text"

func _ready():
	$AnimationPlayer2.play("spin")
	level_list.connect("item_selected", self, "on_item_selected")
	loading.show()
	info.hide()
	page_label.text = "Page: " + str(page)
	back_button.connect("button_down", self, "on_back")
	add_button.connect("button_down", self, "on_add")
	copy_button.connect("button_down", self, "on_copy")
	page_right.connect("button_down", self, "right_pressed")
	buttonx.connect("button_down", self, "x_pressed")
	page_left.connect("button_down", self, "left_pressed")
	comment_button.connect("button_down", self, "comment_pressed")
	search.connect("text_changed", self, "on_text_changed")
	http.connect("request_completed", self, "_on_request_completed")
	request(1)
#	http.request("https://levelsharesquare.com/api/levels?page=1&game=2")
	
func comment_pressed():
	comments.anim_in()
	
func request(pageno):
	http.connect("request_completed", self, "_on_request_completed")
	http.request("https://levelsharesquare.com/api/levels?page=" + str(pageno) + "&game=2&keep=true")
	
func x_pressed():
	searching = false
	http.cancel_request()
	page = 1
	page_label.text = "Page: " + str(page)
	request(page)
	loading.show()
	level_ids.clear()
	level_ratings.clear()
	level_list.clear()
	level_codes.clear()
	search.set_text("")
	creators.clear()
	
func on_text_changed(new_text):
	if " " in new_text:
		var text = search.text
		text.replace(" ", "_")
		search.text = text
		pass

func _process(delta):
	level_list.margin_bottom = 236
	buttonx.margin_left = 303
	buttonx.margin_top = -53
	buttonx.margin_right = 307
	buttonx.margin_bottom = 116
	if Input.is_action_just_pressed("search") && get_focus_owner() == search:
		load_page()
		searching = true
		page = 0
		http3.connect("request_completed", self, "_on_request3_completed")
		var request = "https://levelsharesquare.com/api/levels?page=1&game=2&searchQuery=" + search.get_text() + "&keep=true"
		http3.request(request)
		
func left_pressed():
	if page > 1 && searching == false:
		page -= 1
		load_page()
		request(page)
		
func load_page():
	http.cancel_request()
	actual_codes.clear()
	level_ratings.clear()
	page_label.text = "Page: " + str(page)
	loading.show()
	level_list.clear()
	level_ids.clear()
	level_codes.clear()
	creators.clear()

		
func right_pressed():
	if page < total_pages && searching == false:
		page += 1
		load_page()
		request(page)
		
static func is_valid(value : String):
	value = value.strip_edges(true, true)
	
	var re = RegEx.new()
	re.compile("^[0-9]")

	if not re.search_all(value): # Sorry for the endless if statements
		return false
	else:
		if (
			value.count(",", 0, value.length()) > 2 
			and value.count("[", 0, value.length()) > 0
			and value.count("]", 0, value.length()) > 0
			and value.split(",").size() > 2
		):
			return true
		else:
			return false
			
func on_item_selected(index: int):
	if !level_list.is_item_disabled(0):
		http2.connect("request_completed", self, "_on_request2_completed")
		http2.request("https://levelsharesquare.com/api/users/" + str(creators[index]))
		print(level_ids[index])
		comments.load_comments(level_ids[index])
		yield(get_tree().create_timer(0.6), "timeout")
		rating.set_rating(level_ratings[index])
		
	
func on_back():
	emit_signal("screen_change", "search_screen", "main_menu_screen")
func on_add():
	if level_list.is_anything_selected():
		var level_disk_path = Singleton.SavedLevels.generate_level_disk_path(level_codes[level_list.get_selected_items()[0]])
		var error_code = Singleton.SavedLevels.save_level_to_disk(level_codes[level_list.get_selected_items()[0]], level_disk_path)
		if error_code == OK:
			levels.append(level_codes[level_list.get_selected_items()[0]])
			
		Singleton.SavedLevels.levels_disk_paths.append(level_disk_path)
		Singleton.SavedLevels.save_level_paths_to_disk()
func on_copy():
	if level_list.is_anything_selected():
		var level_code = actual_codes[level_list.get_selected_items()[0]]
		OS.clipboard = str(level_code)


func _on_request3_completed(result, response_code, headers, body):
	level_list.set_item_disabled(0, false)
	var json = JSON.parse(body.get_string_from_utf8())
	page_amt = json.result["levels"].size()
	if page_amt == 0:
		level_list.add_item("No Levels found.")
		level_list.set_item_disabled(0, true)
	else:
		for i in page_amt:
			var level_code = json.result["levels"][i]["code"]
			var level_id = json.result["levels"][i]["_id"]
			var level_rating = json.result["levels"][i]["rating"]
			if is_valid(level_code):
				var level_info : LevelInfo = LevelInfo.new(level_code)
				level_codes.append(level_info)
				level_ids.append(level_id)
				level_ratings.append(level_rating)
				actual_codes.append(level_code)
				level_list.add_item(level_info.level_name)
		for i in page_amt:
			creators.append(json.result["levels"][i]["author"])
	loading.hide()

func _on_request_completed(result, response_code, headers, body):
	if searching == false:
		level_list.set_item_disabled(0, false)
		var json = JSON.parse(body.get_string_from_utf8())
		total_pages = json.result["numberOfPages"]
		page_amt = json.result["levels"].size() - 1
		for i in page_amt:
			var level_code = json.result["levels"][i]["code"]
			var level_id = json.result["levels"][i]["_id"]
			var level_rating = json.result["levels"][i]["rating"]
			if is_valid(level_code):
				var level_info : LevelInfo = LevelInfo.new(level_code)
				level_codes.append(level_info)
				level_ids.append(level_id)
				level_ratings.append(level_rating)
				level_list.add_item(level_info.level_name)
		for i in page_amt:
			creators.append(json.result["levels"][i]["author"])
		loading.hide()
		
func _on_request2_completed(result, response_code, headers, body):
	if !level_list.is_item_disabled(0):
		var json = JSON.parse(body.get_string_from_utf8())
		var username = json.result["user"]["username"]
		populate_info_panel(level_codes[level_list.get_selected_items()[0]], username)
		info.show()
		level_list.get_selected_items()[0] = 0

func populate_info_panel(level_info : LevelInfo = null, username : String = "") -> void:
	if level_info != null:
		level_name_label.text = level_info.level_name
		level_creator.text = username
		

		# Only count shine sprites that have show_in_menu on
		var total_shine_count := 0
		var total_starcoin_details := 0

		for shine_details in level_info.shine_details:
			total_shine_count += 1

		for sc_details in level_info.star_coin_details:
			total_starcoin_details += 1
			
		$Control2/LevelScore/ShineProgressPanel/HBoxContainer2/ShineProgressLabel.text = str(total_shine_count)
		$Control2/LevelScore/StarCoinProgressPanel/HBoxContainer3/StarCoinProgressLabel.text = str(total_starcoin_details)
		
		# set the little thumbnail to look just like the actual level background
		level_sky_thumbnail.texture = level_info.get_level_background_texture()
		level_foreground_thumbnail.modulate = level_info.get_level_background_modulate()
		level_foreground_thumbnail.texture = level_info.get_level_foreground_texture()
		
	else: # no level provided, set everything to empty level values
		info.hide()
