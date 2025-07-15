extends ScrollContainer


export(Resource) var backgrounds
export(Resource) var foregrounds

onready var background_dropdown = $"%BGDropdown"
onready var foreground_dropdown = $"%FGDropdown"
onready var autoscroll_pick = $"%ASPick"

onready var background = $"%Background"
onready var foreground = $"%Foreground"

onready var left_button = $"%LeftButton"
onready var right_button = $"%RightButton"

var bg_index
var fg_index

var current_palette = 0

signal new_selection()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in backgrounds.ids:
		background_dropdown.add_item(i.capitalize())
		
	for i in foregrounds.ids:
		foreground_dropdown.add_item(i.capitalize())
		
	background_dropdown.connect("item_selected", self, "_on_bg_selected")
	foreground_dropdown.connect("item_selected", self, "_on_fg_selected")
	
	left_button.connect("pressed", self, "_on_left_pressed")
	right_button.connect("pressed", self, "_on_right_pressed")
	connect("new_selection", owner, "new_selection")


func _on_bg_selected(index: int):
	var resource = load("res://scenes/shared/background/backgrounds/%s/resource.tres" % backgrounds.ids[index])
	background.texture = resource.texture
	Singleton.CurrentLevelData.level_info.thumbnail_sky = index
	Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.sky = index
	bg_index = index
	emit_signal("new_selection")
	
func _on_fg_selected(index: int):
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[index])
	foreground.texture = resource.preview
	Singleton.CurrentLevelData.level_info.thumbnail_background = index
	Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.background = index
	fg_index = index
	emit_signal("new_selection")
	
func _on_right_pressed():
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	current_palette = wrapi(current_palette + 1, 0, resource.palettes.size())
	if current_palette == 0:
		foreground.texture = resource.preview
	else:
		foreground.texture = resource.palettes[current_palette - 1]
	Singleton.CurrentLevelData.level_info.thumbnail_background_palette = current_palette
	Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.background_palette = current_palette
	emit_signal("new_selection")
		
func _on_left_pressed():
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	current_palette = wrapi(current_palette - 1, 0, resource.palettes.size())
	if current_palette == 0:
		foreground.texture = resource.preview
	else:
		foreground.texture = resource.palettes[current_palette - 1]
	Singleton.CurrentLevelData.level_info.thumbnail_background_palette = current_palette
	Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.background_palette = current_palette
	emit_signal("new_selection")
