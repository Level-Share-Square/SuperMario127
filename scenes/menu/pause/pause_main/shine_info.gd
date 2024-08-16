extends Control

# feels lame but whatever
onready var pause_controller: CanvasLayer = get_parent().get_parent().get_parent()

## nodes
onready var level_name: Label = $LevelName
onready var level_name_back: Label = $LevelName/LevelNameBacking

onready var shine_name: Label = $CenterContainer/ShineDetails/ShineName
onready var shine_description: RichTextLabel = $CenterContainer/ShineDetails/MarginContainer/ShineDescription

onready var buttons = $CenterContainer/ShineDetails/Buttons
onready var index = $CenterContainer/ShineDetails/Buttons/Index
onready var left_button = $CenterContainer/ShineDetails/Buttons/Left
onready var right_button = $CenterContainer/ShineDetails/Buttons/Right


## variables
var level_info: LevelInfo

var total_shines: int
var selected_shine: int
# for viewing a shine sprite other than the one currently selected
var shine_offset: int = 0

func _ready():
	pause_controller.connect("shine_collected", self, "update_shine_info")
	
	level_info = Singleton.CurrentLevelData.level_info
	total_shines = level_info.shine_details.size()
	selected_shine = level_info.selected_shine
	
	update_shine_info()
	scrollcheck()

func update_shine_info():
	level_info = Singleton.CurrentLevelData.level_info
	
	level_name.text = level_info.level_name
	level_name_back.text = level_name.text
	
	if selected_shine == -1: # This can happen if there are no shine sprites in the level
		shine_name.text = "No shine sprite selected"
		shine_description.bbcode_text = "[center]There are no shine sprites in this level.[/center]"
	else:
		var selected_shine_info = level_info.shine_details[selected_shine + shine_offset]
		shine_name.text = selected_shine_info["title"]
		shine_description.bbcode_text = "[center]%s[/center]" % selected_shine_info["description"] 
	
	index.text = str(selected_shine + shine_offset + 1) + "/" + str(total_shines)


func prev_shine():
	if selected_shine + shine_offset >= 1:
		shine_offset -= 1
		
	update_shine_info()
	scrollcheck()

#changes pause menu description to next shine info
func next_shine():
	if (selected_shine + shine_offset) < (total_shines-1):
		shine_offset += 1 
	else:
		shine_offset = shine_offset
	
	update_shine_info()
	scrollcheck()

func scrollcheck():
	if total_shines <= 1:
		buttons.visible = false
	
	
	var is_max_right: bool = (
		(selected_shine + shine_offset) >= (total_shines - 1)
	)
	var is_max_left: bool = (
		selected_shine + shine_offset < 1
	)
	
	right_button.disabled = is_max_right
	left_button.disabled = is_max_left
