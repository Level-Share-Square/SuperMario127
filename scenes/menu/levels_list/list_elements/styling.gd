extends Control

const COMPLETED_COLOR := Color("ffffc4")
const SHINE_MATERIAL: ShaderMaterial = preload("res://scenes/menu/levels_list/list_elements/shine.tres")

# completion
onready var panel = $"%Panel"
onready var thumbnail_edge = $"%Edge"
onready var star = $"%Star"
var is_complete: bool

# thumbnail
onready var thumbnail = $"%Thumbnail"
onready var foreground = $"%Foreground"
onready var level_id: String = get_owner().name
var level_info: LevelInfo
var http_thumbnails: Node


func _ready():
	var thumbnail_url: String = level_info.thumbnail_url
	if thumbnail_url != "":
		var cached_image: ImageTexture = http_thumbnails.get_cached_image(thumbnail_url)
		if cached_image == null:
			http_thumbnails.add_to_queue(thumbnail_url, level_id)
		else:
			load_custom_thumbnail(level_id, cached_image)
	else:
		update_thumbnail()
	
	http_thumbnails.connect("image_loaded", self, "load_custom_thumbnail")
	
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

func load_custom_thumbnail(url: String, texture: ImageTexture):
	if url != level_info.thumbnail_url: return
	
	thumbnail.texture = texture
	foreground.visible = false
