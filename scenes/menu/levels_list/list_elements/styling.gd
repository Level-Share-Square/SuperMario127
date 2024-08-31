extends Control

const COMPLETED_COLOR := Color("ffffc4")
const SHINE_MATERIAL: ShaderMaterial = preload("res://scenes/menu/levels_list/list_elements/shine.tres")

# completion
onready var panel = get_node("%Panel")
onready var thumbnail_edge = get_node("%Edge")
onready var star = get_node("%Star")
var is_complete: bool

# thumbnail
onready var thumbnail = get_node("%Thumbnail")
onready var foreground = get_node("%Foreground")
onready var level_id: String = get_parent().name
var level_info: LevelInfo
var thumbnail_cache: Node

func _ready():
	if level_info.thumbnail_url != "":
		if !(level_id in thumbnail_cache.cached_thumbnails):
			thumbnail_cache.thumbnail_queue.append([level_info.thumbnail_url, level_id])
		else:
			load_custom_thumbnail(level_id)
	else:
		update_thumbnail()
	
	thumbnail_cache.connect("thumbnail_loaded", self, "load_custom_thumbnail")
	
	if is_complete:
		activate_completion_style()
	else:
		star.visible = false

func activate_completion_style():
	panel.material = SHINE_MATERIAL
	panel.modulate = COMPLETED_COLOR
	thumbnail_edge.modulate = COMPLETED_COLOR

func update_thumbnail():
	thumbnail.texture = level_info.get_level_background_texture()
	
	foreground.modulate = level_info.get_level_background_modulate()
	foreground.texture = level_info.get_level_foreground_texture()

func load_custom_thumbnail(id: String):
	if id != level_id: return
	
	if level_id in thumbnail_cache.cached_thumbnails:
		thumbnail.texture = thumbnail_cache.cached_thumbnails[level_id]
		foreground.visible = false
