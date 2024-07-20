extends Screen

var page = 1
var total_pages = 333
var search_cooldown = 5
var searching = false
var load_page_1 = true
var selected_level = ""

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

var page_dictionary : Dictionary
var item_index = 0

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
#	http.request("https://levelsharesquare.com/api/levels?page=1&game=2")
	
func comment_pressed():
	comments.anim_in()
	
func request(pageno):
	http.connect("request_completed", self, "_on_request_completed")
	http.request("https://levelsharesquare.com/api/levels/filter/get?page=" + str(pageno) + "&game=2&authors=true")
	
func x_pressed():
	searching = false
	http.cancel_request()
	page = 1
	page_label.text = "Page: " + str(page)
	request(page)
	loading.show()
	level_list.clear()
	search.set_text("")
	page_dictionary.clear()


func _input(event):
	if search.has_focus():
		if event is InputEventKey and event.is_pressed():
			if event.scancode == KEY_SPACE:
				get_tree().set_input_as_handled()

func _process(delta):
	print(selected_level)
	if "ActiveScreens" in str(get_parent()) && load_page_1 == true:
		request(1)
		load_page_1 = false 
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
		var request = "https://levelsharesquare.com/api/levels/filter/get?page=1&game=2&name=" + search.get_text() + "&authors=true"
		http3.request(request)
		
func left_pressed():
	if page > 1 && searching == false:
		page -= 1
		load_page()
		request(page)
		
func load_page():
	http.cancel_request()
	page_label.text = "Page: " + str(page)
	loading.show()
	level_list.clear()
	page_dictionary.clear()
	comments.comment_dict.clear()

		
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
	item_index = index
	if !level_list.is_item_disabled(0):
		if page_dictionary[index][2] == "":
			var level_code = page_dictionary[index][1]
			http2.connect("request_completed", self, "_on_request2_completed")
			http2.request("https://levelsharesquare.com/api/levels/" + level_code + "/code")
			selected_level = level_code
			comments.load_comments(selected_level)
			yield(get_tree().create_timer(0.6), "timeout")
			rating.set_rating(page_dictionary[index][3])
		else:
			selected_level = page_dictionary[index][1]
			comments.load_comments(page_dictionary[index][1])
			rating.set_rating(page_dictionary[index][3])
			populate_info_panel(LevelInfo.new(page_dictionary[item_index][2]), page_dictionary[item_index][4])
			info.show()
			level_list.get_selected_items()[0] = 0
		
	
func on_back():
	emit_signal("screen_change", "search_screen", "main_menu_screen")
func on_add():
	if level_list.is_anything_selected():
		var level_disk_path = Singleton.SavedLevels.generate_level_disk_path(page_dictionary[level_list.get_selected_items()[0]][2])
		var error_code = Singleton.SavedLevels.save_level_to_disk(page_dictionary[level_list.get_selected_items()[0]][2], level_disk_path)
		if error_code == OK:
			levels.append(page_dictionary[level_list.get_selected_items()[0]][2])
			
		Singleton.SavedLevels.levels_disk_paths.append(level_disk_path)
		Singleton.SavedLevels.save_level_paths_to_disk()
func on_copy():
	if level_list.is_anything_selected():
		var level_code = page_dictionary[level_list.get_selected_items()[0]][2]
		OS.clipboard = str(level_code)


func _on_request3_completed(result, response_code, headers, body):
	level_list.set_item_disabled(0, false)
	var json = JSON.parse(body.get_string_from_utf8())
	if "message" in str(json.result):
		level_list.add_item("No Levels found.")
		level_list.set_item_disabled(0, true)
		loading.hide()
		return
	page_amt = json.result["levels"].size()
	if page_amt == 0:
		level_list.add_item("No Levels found.")
		level_list.set_item_disabled(0, true)
	else:
		for i in page_amt:
			var level_id = json.result["levels"][i]["_id"]
			var level_rating = json.result["levels"][i]["rating"]
			var level_name = json.result["levels"][i]["name"]
			var username = json.result["levels"][i]["author"]["username"]
			page_dictionary[i] = [level_name, level_id, "", level_rating, username]
	loading.hide()

func _on_request_completed(result, response_code, headers, body):
	if searching == false:
		level_list.set_item_disabled(0, false)
		var json = JSON.parse(body.get_string_from_utf8())
		total_pages = json.result["numberOfPages"]
		page_amt = json.result["levels"].size()
		for i in page_amt:
			var level_id = json.result["levels"][i]["_id"]
			var level_rating = json.result["levels"][i]["rating"]
			var level_name = json.result["levels"][i]["name"]
			var username = json.result["levels"][i]["author"]["username"]
			page_dictionary[i] = [level_name, level_id, "", level_rating, username]
			level_list.add_item(level_name)
		loading.hide()
		
func _on_request2_completed(result, response_code, headers, body):
	print(response_code)
	if !level_list.is_item_disabled(0):
		var json = JSON.parse(body.get_string_from_utf8())
		page_dictionary[item_index][2] = json.result["levelData"]
		populate_info_panel(LevelInfo.new(page_dictionary[item_index][2]), page_dictionary[item_index][4])
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
