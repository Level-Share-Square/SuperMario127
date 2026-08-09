extends Control

# feels lame but whatever
onready var pause_controller: CanvasLayer = get_parent().get_parent().get_parent()

## nodes
onready var level_name: Label = $LevelName
onready var level_name_back: Label = $LevelName/LevelNameBacking

onready var star = $CenterContainer/ShineDetails/HBoxContainer/Star
onready var shine_name = $CenterContainer/ShineDetails/HBoxContainer/ShineName
onready var shine_description: RichTextLabel = $CenterContainer/ShineDetails/MarginContainer/ShineDescription

onready var buttons = $CenterContainer/ShineDetails/Buttons
onready var index = $CenterContainer/ShineDetails/Buttons/Index
onready var left_button = $CenterContainer/ShineDetails/Buttons/Left
onready var right_button = $CenterContainer/ShineDetails/Buttons/Right

onready var level_metadata: LevelMetadata = CurrentLevelData.level_metadata

## variables

var total_shines: int
var selected_shine_id: String
var selected_shine_index: int
# for viewing a shine sprite other than the one currently selected
var shine_offset: int = 0

func _ready():
	pause_controller.connect("shine_collected", self, "update_shine_info")
	
#	level_info = CurrentLevelData.level_info
	
	if is_instance_valid(level_metadata):
		total_shines = level_metadata.collectible_data.used_mission_data.size()
		selected_shine_id = CurrentLevelData.current_mission_id
		selected_shine_index = level_metadata.collectible_data.used_mission_data.keys().find(selected_shine_id)
		
		update_shine_info()
		scrollcheck()


func update_shine_info():
#	level_info = CurrentLevelData.level_info
	var selected_shine_info = CurrentLevelData.level_metadata.collectible_data.mission_data[selected_shine_index + shine_offset]
	
	star.visible = false
	level_name.text = CurrentLevelData.level_metadata.level_name
	level_name_back.text = CurrentLevelData.level_metadata.level_name
	
	if selected_shine_id == "": # This can happen if there are no shine sprites in the level
		shine_name.text = "No shine sprite selected"
		shine_description.bbcode_text = "[center]There are no shine sprites in this level.[/center]"
	else:
		shine_name.text = selected_shine_info.shine_name
		shine_description.bbcode_text = "[center]%s[/center]" % selected_shine_info.shine_description
		star.visible = CurrentLevelData.save_data.is_mission_complete(selected_shine_info.mission_uuid)
		star.visible = false
	
	index.text = str(selected_shine_index + shine_offset + 1) + "/" + str(total_shines)


func prev_shine():
	if selected_shine_index + shine_offset >= 1:
		shine_offset -= 1
		
	update_shine_info()
	scrollcheck()

#changes pause menu description to next shine info
func next_shine():
	if (selected_shine_index + shine_offset) < (total_shines-1):
		shine_offset += 1 
	else:
		shine_offset = shine_offset
	
	update_shine_info()
	scrollcheck()

func scrollcheck():
	if total_shines <= 1:
		buttons.visible = false
	
	
	var is_max_right: bool = (
		(selected_shine_index + shine_offset) >= (total_shines - 1)
	)
	var is_max_left: bool = (
		selected_shine_index + shine_offset < 1
	)
	
	right_button.disabled = is_max_right
	left_button.disabled = is_max_left
