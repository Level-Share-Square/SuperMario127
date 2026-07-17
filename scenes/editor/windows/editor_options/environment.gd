extends ScrollContainer


export(Resource) var backgrounds
export(Resource) var foregrounds

var bg_index: int = 0
var fg_index: int = 0

var current_palette = 0

onready var bg_palette_button_scene = preload("res://scenes/editor/windows/editor_options/bg_palette_button.tscn")

onready var background_dropdown = $"%BGDropdown"
onready var foreground_dropdown = $"%FGDropdown"
onready var autoscroll_pick = $"%ASPick"

onready var bg_container = $"%BGContainer"
onready var background = $"%Background"
onready var foreground = $"%Foreground"

onready var palette_menu_button = $"%PaletteMenuButton"
onready var palettes_container = $"%PalettesContainer"
onready var palette_menu = $"%PalettesGrid"

signal update_background()


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in backgrounds.ids.size():
		background_dropdown.add_item(backgrounds.ids[i].capitalize(), i)
		
	for i in foregrounds.ids.size():
		foreground_dropdown.add_item(foregrounds.ids[i].capitalize(), i)
		
	background_dropdown.connect("item_selected", self, "_on_bg_selected")
	foreground_dropdown.connect("item_selected", self, "_on_fg_selected")
	
	palette_menu_button.connect("pressed", self, "_on_palette_menu_opened")
	
#	# I was wrong dignity... sorry... we can just do this on ready
#	area = CurrentLevelData.area.header
	
	autoscroll_pick.connect("value_changed", self, "_on_autoscroll_change")
	connect("update_background", owner, "update_background")
	
	load_settings()


func load_settings():
	bg_index = CurrentLevelData.area.header.sky
	fg_index = CurrentLevelData.area.header.background
	var background_resource = load("res://scenes/shared/background/backgrounds/%s/resource.tres" % backgrounds.ids[bg_index])
	var foreground_resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	current_palette = CurrentLevelData.area.header.background_palette
	background.texture = background_resource.texture
	if current_palette == 0:
		foreground.texture = foreground_resource.preview
	else:
		foreground.texture = foreground_resource.palettes[current_palette - 1]
	yield(get_tree(), "idle_frame")
	background_dropdown.select(bg_index)
	foreground_dropdown.select(fg_index)
	autoscroll_pick.value = CurrentLevelData.area.header.bg_autoscroll_speed
	_init_palette_dropdown()


# adds the palette previews to the grid 
func _init_palette_dropdown():
	#init and clear previous entries
	for child in palette_menu.get_children():
		palette_menu.remove_child(child)
	
	var fg_resource: ForegroundResource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
	var bg_resource: SkyResource = load("res://scenes/shared/background/backgrounds/%s/resource.tres" % backgrounds.ids[bg_index])
	#(for default palette since its coded differently)
	var default_palette: BGPaletteButton = bg_palette_button_scene.instance()
	default_palette.setup_button(fg_resource.preview, bg_resource)
	default_palette.connect("gui_input", self, "_on_palette_selected", [0])
	palette_menu.add_child(default_palette)
	
	for i in range(fg_resource.palettes.size()):
		var palette_button: BGPaletteButton = bg_palette_button_scene.instance()
		palette_button.setup_button(fg_resource.palettes[i], bg_resource)
		palette_button.connect("gui_input", self, "_on_palette_selected", [i + 1])
		palette_menu.add_child(palette_button)


func _on_palette_selected(event: InputEvent, index: int):
	if not event is InputEventMouseButton:
		return
	
	if event.is_action_pressed("LMB"):
		var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[fg_index])
		var palettes = resource.palettes
		current_palette = index
		if current_palette == 0:
			foreground.texture = resource.preview
		else:
			foreground.texture = palettes[current_palette - 1]
		
		# Note: This should probably be in the save function instead.
#		CurrentLevelData.level_info.thumbnail_background_palette = current_palette
		CurrentLevelData.area.header.background_palette = current_palette
		emit_signal("update_background")

		bg_container.show()
		palettes_container.hide()


func _on_bg_selected(index: int):
	var resource: SkyResource = load("res://scenes/shared/background/backgrounds/%s/resource.tres" % backgrounds.ids[index])
	background.texture = resource.texture
	# Note: This should probably be in the save function instead.
#	CurrentLevelData.level_info.thumbnail_sky = index
	foreground.modulate = resource.parallax_modulate
	CurrentLevelData.area.header.sky = index
	bg_index = index
	_init_palette_dropdown()
	emit_signal("update_background")


func _on_fg_selected(index: int):
	current_palette = 0
	var resource = load("res://scenes/shared/background/foregrounds/%s/resource.tres" % foregrounds.ids[index])
	foreground.texture = resource.preview
	# Note: This should probably be in the save function instead.
#	CurrentLevelData.level_info.thumbnail_background = index
	CurrentLevelData.area.header.background = index
	CurrentLevelData.area.header.background_palette = 0
	fg_index = index
	_init_palette_dropdown()
	emit_signal("update_background")


func _on_palette_menu_opened():
	bg_container.hide()
	palettes_container.show()
	_init_palette_dropdown()


func _on_autoscroll_change(value):
	CurrentLevelData.area.header.bg_autoscroll_speed = value
	emit_signal("update_background")
