extends Node2D

onready var backgrounds = $Backgrounds

const PICKED_BACKGROUND = 7
const PICKED_PARALLAX = 21

func _ready():
	var extra_offset = 65
	
	backgrounds.update_background(PICKED_BACKGROUND, PICKED_PARALLAX, Rect2(0, 0, 24, 14), extra_offset, 0)
	backgrounds.do_auto_scroll = true
