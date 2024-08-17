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
var level_info: LevelInfo

func _ready():
	update_thumbnail()
	
	if is_complete:
		activate_completion_style()
	else:
		star.visible = false

func activate_completion_style():
	panel.material = SHINE_MATERIAL
	panel.modulate = COMPLETED_COLOR
	thumbnail_edge.modulate = COMPLETED_COLOR
	
	# we dont need this node anymore might as well
	queue_free()

func update_thumbnail():
	thumbnail.texture = level_info.get_level_background_texture()
	
	foreground.modulate = level_info.get_level_background_modulate()
	foreground.texture = level_info.get_level_foreground_texture()
