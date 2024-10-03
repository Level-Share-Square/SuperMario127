extends Node2D


onready var backgrounds = $Backgrounds

const BG_ID: int = 10
const PARALLAX_ID: int = 1
const PARALLAX_OFFSET: int = 160
const PARALLAX_PALETTE: int = 1


func _ready():
	backgrounds.do_auto_scroll = true
	backgrounds.update_background(
		BG_ID, 
		PARALLAX_ID, 
		Rect2(0, 0, 24, 14), 
		PARALLAX_OFFSET,
		PARALLAX_PALETTE
	)
