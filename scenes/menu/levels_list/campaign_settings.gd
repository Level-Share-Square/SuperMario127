extends Control


const DEFAULT_TEXT: String = "None"

onready var list_handler = $"%ListHandler"
onready var level_grid = $"%LevelGrid"
onready var title = $InfoTab/Info/Title
onready var author = $InfoTab/Info/Author
onready var description = $InfoTab/Info/Panel/MarginContainer/Description
onready var intro_option = $InfoTab/Info/Intro/IntroOption
onready var hub_option = $InfoTab/Info/Hub/HubOption
onready var thumbnail = $VBoxContainer/Thumbnail

var campaign_id: String
var campaign_path: String
var info_dict: Dictionary

var level_ids: Array = []


func load_campaign_info(_campaign_path: String) -> void:
	if not list_handler.is_campaign: return
	
	campaign_path = _campaign_path
	campaign_id = level_list_util.get_last_in_path(campaign_path)
	
	info_dict = campaign_info_util.load_info_file(campaign_path)
	title.text = campaign_id
	author.text = info_dict.get("author", "Unknown")
	description.text = info_dict.get("description", "Error loading campaign info.")
	
	intro_option.clear()
	hub_option.clear()
	
	intro_option.add_item(DEFAULT_TEXT)
	hub_option.add_item(DEFAULT_TEXT)
	
	level_ids = []
	
	level_grid.disconnect("child_entered_tree", self, "card_added")
	level_grid.disconnect("child_exited_tree", self, "card_removed")
	
	for card in level_grid.get_children():
		card_added(card)
		
	level_grid.connect("child_entered_tree", self, "card_added")
	level_grid.connect("child_exited_tree", self, "card_removed")


func card_added(card: BaseCard):
	if card is LevelCard:
		level_ids.append(card.level_info.level_id)
		intro_option.add_item(card.level_info.level_name)
		hub_option.add_item(card.level_info.level_name)
		
		if not info_dict.empty():
			if info_dict.get("intro_level", "") == card.level_info.level_id:
				intro_option.select(level_ids.size())
			if info_dict.get("hub_level", "") == card.level_info.level_id:
				hub_option.select(level_ids.size())


func card_removed(card: BaseCard):
	if card is LevelCard:
		var index = level_ids.find(card.level_info.level_id)
		
		if intro_option.selected == index + 1:
			intro_option.select(0)
		if hub_option.selected == index + 1:
			hub_option.select(0)
		
		intro_option.remove_item(index + 1)
		hub_option.remove_item(index + 1)


func rename_campaign():
	var campaign_name: String = title.text
	if campaign_name == campaign_id: return
	
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9 ]")
	
	var result: RegExMatch = regex.search(campaign_name)
	if result:
		print("Invalid campaign name. Offending character: " + result.get_string())
		return
	
	var parent_path: String = level_list_util.get_parent_from_path(list_handler.working_folder)
	campaign_path = level_list_util.get_folder_path(campaign_name, parent_path)
	if level_list_util.dir_exists(campaign_path): 
		print("Campaign already exists.")
		return
	
	level_list_util.rename_campaign_folder(list_handler.working_folder, campaign_name)
	list_handler.working_folder = campaign_path


func save_info():
	rename_campaign()
	info_dict["author"] = author.text
	info_dict["description"] = description.text
	info_dict["hub_level"] = level_ids[hub_option.selected - 1] if hub_option.selected > 0 else ""
	info_dict["intro_level"] = level_ids[intro_option.selected - 1] if intro_option.selected > 0 else ""
	
	campaign_info_util.save_info_file(campaign_path, info_dict)
