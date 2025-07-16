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

var bg_index: int = 0
var fg_index: int = 0

var current_palette = 0

var area: LevelArea

signal update_background()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in backgrounds.ids.size():
		background_dropdown.add_item(backgrounds.ids[i].capitalize(), i)
		
	for i in foregrounds.ids.size():
		foreground_dropdown.add_item(foregrounds.ids[i].capitalize(), i)
		
	background_dropdown.connect("item_selected", self, "_on_bg_selected")
	foreground_dropdown.connect("item_selected", self, "_on_fg_selected")
	
	left_button.connect("pressed", self, "_on_left_pressed")
	right_button.connect("pressed", self, "_on_right_pressed")
	
	# I was wrong dignity... sorry... we can just do this on ready
	area = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area]
	
	autoscroll_pick.connect("value_changed", self, "_on_autoscroll_change")
	connect("update_background", owner, "update_background")
	
	load_settings()


func load_settings():
	bg_index = area.settings.sky
	fg_index = area.settings.background
	var background_resource = load("res://scenes/shared/background/backgrounds/%s/resource.tres" % backgrounds.ids[bg_index])
	var foreground_resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	current_palette = area.settings.background_palette
	background.texture = background_resource.texture
	if current_palette == 0:
		foreground.texture = foreground_resource.preview
	else:
		foreground.texture = foreground_resource.palettes[current_palette - 1]
	yield(get_tree(), "idle_frame")
	background_dropdown.select(bg_index)
	foreground_dropdown.select(fg_index)
	autoscroll_pick.value = area.settings.bg_autoscroll_speed


func _on_bg_selected(index: int):
	var resource = load("res://scenes/shared/background/backgrounds/%s/resource.tres" % backgrounds.ids[index])
	background.texture = resource.texture
	Singleton.CurrentLevelData.level_info.thumbnail_sky = index
	area.settings.sky = index
	bg_index = index
	emit_signal("update_background")


func _on_fg_selected(index: int):
	current_palette = 0
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[index])
	foreground.texture = resource.preview
	Singleton.CurrentLevelData.level_info.thumbnail_background = index
	area.settings.background = index
	area.settings.background_palette = 0
	fg_index = index
	emit_signal("update_background")


func _on_right_pressed():
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	if resource.palettes.size() > 0:
		current_palette = wrapi(current_palette + 1, 0, resource.palettes.size())
		if current_palette == 0:
			foreground.texture = resource.preview
		else:
			foreground.texture = resource.palettes[current_palette - 1]
		Singleton.CurrentLevelData.level_info.thumbnail_background_palette = current_palette
		area.settings.background_palette = current_palette
		emit_signal("update_background")


func _on_left_pressed():
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	if resource.palettes.size() != null:
		current_palette = wrapi(current_palette - 1, 0, resource.palettes.size())
		if current_palette == 0:
			foreground.texture = resource.preview
		else:
			foreground.texture = resource.palettes[current_palette - 1]
		Singleton.CurrentLevelData.level_info.thumbnail_background_palette = current_palette
		area.settings.background_palette = current_palette
		emit_signal("update_background")


func _on_autoscroll_change(value):
	area.settings.bg_autoscroll_speed = value
	emit_signal("update_background")
