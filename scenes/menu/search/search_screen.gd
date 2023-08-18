extends Screen

var page = 1
var total_pages = 333
var level_codes = []
var creators = []
var populate_index

var levels = Singleton.SavedLevels.levels

onready var loading = $Loading
onready var level_name_label = $Control2/LevelInfo/LevelName
onready var back_button = $Control/VBoxContainer/HBoxContainer/ButtonBack
onready var add_button = $Control/VBoxContainer/HBoxContainer/ButtonAdd
onready var copy_button = $Control/VBoxContainer/HBoxContainer/ButtonCopyCode
onready var level_creator = $Control2/LevelCreator
onready var level_sky_thumbnail = $Control2/LevelInfo/LevelThumbnail/PanelContainer/ThumbnailImage
onready var level_foreground_thumbnail = $Control2/LevelInfo/LevelThumbnail/PanelContainer/ForegroundThumbnailImage
onready var info = $Control2
onready var search = $Control/PanelContainer/TextEdit
onready var page_label = $Control/PageSelect/Value
onready var page_right = $Control/PageSelect/Right
onready var page_left = $Control/PageSelect/Left
onready var level_list = $Control/VBoxContainer/LevelListPanel/VBoxContainer/LevelList
onready var http = $HTTPRequest
onready var http2 = $HTTPRequest2
onready var page_amt = 10
# var a = 2
# var b = "text"

func _ready():
	level_list.connect("item_selected", self, "on_item_selected")
	loading.show()
	info.hide()
	page_label.text = str(page)
	back_button.connect("button_down", self, "on_back")
	add_button.connect("button_down", self, "on_add")
	copy_button.connect("button_down", self, "on_copy")
	page_right.connect("button_down", self, "right_pressed")
	page_left.connect("button_down", self, "left_pressed")
	http.connect("request_completed", self, "_on_request_completed")
	http.request("https://levelsharesquare.com/api/levels?page=1&game=2")
	
func request(pageno):
	http.connect("request_completed", self, "_on_request_completed")
	http.request("https://levelsharesquare.com/api/levels?page=" + str(pageno) + "&game=2")
	
func left_pressed():
	if page > 1:
		http.cancel_request()
		page -= 1
		page_label.text = str(page)
		request(page)
		loading.show()
		level_list.clear()
		level_codes.clear()
		
func right_pressed():
	if page < total_pages:
		http.cancel_request()
		page += 1
		page_label.text = str(page)
		request(page)
		loading.show()
		level_list.clear()
		level_codes.clear()

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
	http2.connect("request_completed", self, "_on_request2_completed")
	http2.request("https://levelsharesquare.com/api/users/" + str(creators[index]))
	populate_index = index
	
func on_back():
	emit_signal("screen_change", "search_screen", "main_menu_screen")
func on_add():
	if level_list.is_anything_selected():
		var level_disk_path = Singleton.SavedLevels.generate_level_disk_path(level_codes[populate_index])
		var error_code = Singleton.SavedLevels.save_level_to_disk(level_codes[populate_index], level_disk_path)
		if error_code == OK:
			levels.append(level_codes[populate_index])
			
		Singleton.SavedLevels.levels_disk_paths.append(level_disk_path)
		Singleton.SavedLevels.save_level_paths_to_disk()


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	total_pages = json.result["numberOfPages"]
	page_amt = json.result["levels"].size() - 1
	for i in page_amt:
		var level_code = json.result["levels"][i]["code"]
		if is_valid(level_code) && !i == 4:
			var level_info : LevelInfo = LevelInfo.new(level_code)
			level_codes.append(level_info)
			level_list.add_item(level_info.level_name)
			print(i)
	for i in page_amt:
		creators.append(json.result["levels"][i]["author"])
	loading.hide()
	
func _on_request2_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var username = json.result["user"]["username"]
	populate_info_panel(level_codes[populate_index], username)
	info.show()
	populate_index = 0

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
