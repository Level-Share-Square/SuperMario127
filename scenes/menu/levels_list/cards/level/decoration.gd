extends Control

const COMPLETED_COLOR := Color("ffffc4")
const SHINE_MATERIAL: ShaderMaterial = preload("res://scenes/menu/levels_list/cards/level/shine.tres")

## nodes
onready var level_card: LevelCard = get_owner()
onready var visibility_enabler_2d := $"%VisibilityEnabler2D"
onready var default_thumbnail = preload("res://.import/default_thumb.png-3e78509f186eb58e5a939ece4213411a.stex")

onready var panel := $"%Panel"
onready var thumbnail_edge := $"%Edge"
onready var star := $"%Star"

onready var thumbnail := $"%Thumbnail"
onready var foreground := $"%Foreground"
onready var name_label := $"%Name"

## external
var level_info: LevelInfo


func _ready():
	level_info = level_card.level_info
	name_label.text = level_info.level_name
	
	var is_valid: bool = level_info.validity_check.is_valid
	
	if (!is_valid):
		level_info.level_name = "Invalid Level"
		name_label.text = "Invalid Level"
		thumbnail.texture = default_thumbnail
	else:
		load_custom_thumbnail(level_info.thumbnail_url)
	
	if level_card.has_save and level_info.is_fully_completed():
		activate_completion_style()
	else:
		star.call_deferred("hide")


func activate_completion_style():
	panel.material = SHINE_MATERIAL
	panel.modulate = COMPLETED_COLOR
	thumbnail_edge.modulate = COMPLETED_COLOR


func load_default_thumbnail(_viewport: Viewport = null):
	thumbnail.texture = level_info.get_level_background_texture()
	
	foreground.modulate = level_info.get_level_background_modulate()
	foreground.texture = level_info.get_level_foreground_texture()


func load_custom_thumbnail(url: String):
	var thumbnail_texture: ImageTexture = yield(AssetHandler.load_image(url, CurrentLevelData.working_folder), "completed")
	
	if !thumbnail_texture:
		load_default_thumbnail()
		return
	
	thumbnail.texture = thumbnail_texture
	
