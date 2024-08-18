extends Node2D

onready var backgrounds = $Backgrounds

export var blur_path : NodePath
var blur_node : ColorRect

const BG_ID = 7
const PARALLAX_ID = 21
const PARALLAX_OFFSET = 20
const BLUR = 1
const DARK_BG_ID = 8
const DARK_PARALLAX_ID = 18
const DARK_PARALLAX_OFFSET = 140
const DARK_BLUR = 0.5

func _ready():
	Singleton2.connect("dark_mode_toggled", self, "dark_mode_toggled")
	blur_node = get_node(blur_path)
	#some weird shit i had to do to make offset work correclty because the update background function is implemented weird..
	backgrounds.update_background(BG_ID, PARALLAX_ID, Rect2(0, 0, 24, 14), PARALLAX_OFFSET, 0)
	backgrounds.update_background(DARK_BG_ID, DARK_PARALLAX_ID, Rect2(0, 0, 24, 14), DARK_PARALLAX_OFFSET, 0)
	dark_mode_toggled()
	backgrounds.do_auto_scroll = true
	
	
func dark_mode_toggled():
	if Singleton2.dark_mode:
		update_bg(DARK_BG_ID, DARK_PARALLAX_ID)
		blur_node.material.set_shader_param("blur_amount", DARK_BLUR)
	else:
		update_bg(BG_ID, PARALLAX_ID)
		blur_node.material.set_shader_param("blur_amount", BLUR)
	
func update_bg(bg_id, parallax_id):
	backgrounds.update_background(bg_id, parallax_id, Rect2(0, 0, 24, 14), 0, 0)
