extends VBoxContainer


signal character_changed(new_character)

const PALETTE_IDS: IdMap = preload("res://scenes/actors/mario/palettes/ids.tres")
const PALETTE_BUTTON_SCENE: PackedScene = preload("res://scenes/menu/options/character/palette_button.tscn")
const CHAR_NAMES: Array = ["Mario", "Luigi"]

onready var button_group := ButtonGroup.new()
onready var row_1 = $Row1
onready var row_2 = $Row2
onready var row_3 = $Row3
onready var row_4 = $Row4

onready var char_name_label = $"%CharNameLabel"
onready var char_name_label_backing = $"%CharNameLabelBacking"
onready var character_sprite = $"%CharacterSprite"
onready var palette_label = $"%PaletteLabel"
onready var palette_label_backing = $"%PaletteLabelBacking"
onready var mario_button = $"%MarioButton"
onready var luigi_button = $"%LuigiButton"

var current_character: int = -1
var current_palette: String = "default"

var is_loaded: bool = false

func visibility_changed():
	if is_loaded: return
	is_loaded = true
	
	set_character(LocalSettings.load_setting("General", "first_player", 0))
	set_palette(LocalSettings.load_setting("General", "char_palette", "default"))
	
	var index: int
	var last_button: PaletteButton
	for palette_id in PALETTE_IDS.ids:
		var palette_button: PaletteButton = PALETTE_BUTTON_SCENE.instance()
		palette_button.palette_id = palette_id
		palette_button.character = current_character
		palette_button.group = button_group
		palette_button.pressed = (palette_id == current_palette)
		palette_button.connect("button_down", self, "set_palette", [palette_id])
		connect("character_changed", palette_button, "load_palette")
		
		var destination: HBoxContainer = row_1
		var wrapped_index: int = wrapi(index, 0, 4)
		match wrapped_index:
			1:
				destination = row_2
			2:
				destination = row_3
			3:
				destination = row_4
		destination.add_child(palette_button)
		
		if wrapped_index > 0:
			palette_button.focus_neighbour_top = palette_button.get_path_to(last_button)
			last_button.focus_neighbour_bottom = last_button.get_path_to(palette_button)
		
		last_button = palette_button
		index += 1

func set_palette(new_palette: String):
	if current_palette == new_palette: return
	current_palette = new_palette
	character_sprite.set_palette(current_palette)
	palette_label.text = current_palette.capitalize()
	palette_label_backing.text = palette_label.text
	LocalSettings.change_setting("General", "char_palette", new_palette)

func set_character(new_character: int):
	if current_character == new_character: return
	current_character = new_character
	char_name_label.text = CHAR_NAMES[current_character]
	char_name_label_backing.text = char_name_label.text
	character_sprite.set_character(current_character)
	emit_signal("character_changed", current_character)
	LocalSettings.change_setting("General", "first_player", new_character)
	
	mario_button.pressed = (new_character == 0)
	luigi_button.pressed = not mario_button.pressed
