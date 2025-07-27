tool
extends AnimatedSprite

onready var parent: Control = get_parent()
const PALETTES_PATH: String = "res://scenes/actors/mario/palettes/%s/%s.png"
const CHAR_NAMES: Array = ["Mario", "Luigi"]
const CHAR_FRAMES: Array = [
	preload("res://scenes/menu/options/character/mario_frames.tres"),
	preload("res://scenes/menu/options/character/luigi_frames.tres")
]
const IN_PALETTES: Array = [
	preload("res://scenes/actors/mario/palettes/mario/default.png"),
	preload("res://scenes/actors/mario/palettes/luigi/default.png")
]

var current_character: int = 0
var current_palette: String = "default"

func _ready():
	parent.connect("resized", self, "recenter")
	recenter()

func recenter():
	position.x = parent.rect_size.x / 2

func set_palette(palette_id: String):
	current_palette = palette_id
	
	var char_name: String = CHAR_NAMES[current_character]
	var palette_texture: StreamTexture = load(PALETTES_PATH % [char_name.to_lower(), palette_id])
	material.set_shader_param("palette_in", IN_PALETTES[current_character])
	material.set_shader_param("palette_out", palette_texture)

func set_character(new_character: int):
	current_character = new_character
	frames = CHAR_FRAMES[new_character]
	frame = 0
	set_palette(current_palette)
	play("selected")
