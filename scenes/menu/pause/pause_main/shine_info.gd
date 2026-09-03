extends Control

# feels lame but whatever
onready var pause_controller: CanvasLayer = get_parent().get_parent().get_parent()

## nodes
onready var level_name: Label = $LevelName
onready var level_name_back: Label = $LevelName/LevelNameBacking

onready var star = $CenterContainer/ShineDetails/HBoxContainer/Star
onready var shine_name = $CenterContainer/ShineDetails/HBoxContainer/ShineName
onready var shine_description: RichTextLabel = $CenterContainer/ShineDetails/MarginContainer/ShineDescription

onready var buttons = $"%Hideable"
onready var index = $"%Index"
onready var left_button = $"%Left"
onready var right_button = $"%Right"

onready var switch_collectible = $"%SwitchCollectible"
onready var star_coin_icon = $"%SwitchCollectible/StarCoin"
onready var shine_icon = $"%SwitchCollectible/Shine"

onready var level_metadata: LevelMetadata = CurrentLevelData.level_metadata

## variables

enum CollectibleType { SHINE, STAR_COIN }
var cur_collectible: int = CollectibleType.SHINE

var total_shines: int
var selected_shine_id: String
var selected_shine_index: int
# for viewing a shine sprite other than the one currently selected
var shine_offset: int = 0

var total_scoins: int
var selected_scoin_index: int

var show_in_menu_missions: Array

func _ready():
	pause_controller.connect("shine_collected", self, "update_info")
	pause_controller.connect("star_coin_collected", self, "update_info")
	
#	level_info = CurrentLevelData.level_info
	get_show_in_menu_mission()
	
	if is_instance_valid(level_metadata):
		var collectible_data: CollectibleData = level_metadata.collectible_data
		
		total_shines = collectible_data.get_menu_shine_count()
		selected_shine_id = CurrentLevelData.current_mission_id
		selected_shine_index = show_in_menu_missions.find(selected_shine_id)
		
		total_scoins = collectible_data.get_star_coin_count()
		selected_scoin_index = 0
		
		update_info()
		scrollcheck()

func get_show_in_menu_mission():
	show_in_menu_missions.clear()
	for mission in level_metadata.collectible_data.used_mission_data:
		if level_metadata.collectible_data.get_mission_by_uuid(mission).mission_show_in_menu: show_in_menu_missions.append(mission)

func update_info():
	star.visible = false
	level_name.text = CurrentLevelData.level_metadata.level_name
	level_name_back.text = CurrentLevelData.level_metadata.level_name
	if cur_collectible == CollectibleType.SHINE:
		update_shine_info()
	else:
		update_scoin_info()


func update_shine_info():
	if total_shines <= 0: # This can happen if there are no shine sprites in the level
		shine_name.text = "No shine sprite selected"
		shine_description.bbcode_text = "[center]There are no shine sprites in this level.[/center]"
	else:
		var selected_shine_info = level_metadata.collectible_data.get_mission_by_uuid(show_in_menu_missions[selected_shine_index + shine_offset])
		shine_name.text = selected_shine_info.shine_name
		shine_description.bbcode_text = "[center]%s[/center]" % selected_shine_info.shine_description
		star.visible = CurrentLevelData.save_data.is_mission_complete(selected_shine_info.mission_uuid)
	
	index.text = str(selected_shine_index + shine_offset + 1) + "/" + str(total_shines)


func update_scoin_info():
	if total_scoins <= 0:
		shine_name.text = "No star coin selected"
		shine_description.bbcode_text = "[center]There are no star coins in this level.[/center]"
	else:
		var selected_scoin_data: StarCoinData = level_metadata.collectible_data.star_coin_data[selected_scoin_index]
		shine_name.text = "Star Coin %s" % (selected_scoin_index + 1)
		shine_description.bbcode_text = "[center]%s[/center]" % selected_scoin_data.star_coin_hint
		star.visible = CurrentLevelData.save_data.is_star_coin_collected(selected_scoin_data.star_coin_uuid)
	
	index.text = str(selected_scoin_index + 1) + "/" + str(total_scoins)


func switch_collectible_type() -> void:
	cur_collectible = CollectibleType.STAR_COIN if cur_collectible == CollectibleType.SHINE else CollectibleType.SHINE
	shine_icon.visible = false if cur_collectible == CollectibleType.SHINE else CollectibleType.STAR_COIN
	star_coin_icon.visible = not shine_icon.visible
	
	update_info()
	scrollcheck()
	

func prev_shine():
	if cur_collectible == CollectibleType.SHINE:
		if selected_shine_index + shine_offset >= 1:
			shine_offset -= 1
	else:
		if selected_scoin_index >= 1:
			selected_scoin_index -= 1
		
	update_info()
	scrollcheck()

#changes pause menu description to next shine info
func next_shine():
	if cur_collectible == CollectibleType.SHINE:
		if (selected_shine_index + shine_offset) < (total_shines-1):
			shine_offset += 1 
	else:
		if selected_scoin_index < (total_scoins-1):
			selected_scoin_index += 1 
	
	update_info()
	scrollcheck()

func scrollcheck():
	var total: int = total_shines
	var index: int = selected_shine_index
	var offset: int = shine_offset
	
	if cur_collectible == CollectibleType.STAR_COIN:
		total = total_scoins
		index = selected_scoin_index
		offset = 0
	
	buttons.visible = (total > 1)
	
	var is_max_right: bool = (
		(index + offset) >= (total - 1)
	)
	var is_max_left: bool = (
		index + offset < 1
	)
	
	right_button.disabled = is_max_right
	left_button.disabled = is_max_left
