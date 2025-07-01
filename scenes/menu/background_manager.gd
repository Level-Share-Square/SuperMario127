extends Node2D


onready var backgrounds = $Backgrounds

const BG_ID: int = 1
const PARALLAX_ID: int = 13
const PARALLAX_OFFSET: int = 65
const PARALLAX_PALETTE: int = 0
const SCROLL_SPEED: float = 300.0

const BACKGROUNDS := [
	[1, 13, 0, 64],
	[6, 1, 3, 160],
	[10, 5, 0, 128],
	[6, 13, 3, 64],
]

var current_star_coins: int = 100
var total_star_coins: int = 100


func _ready():
	var preset = get_random_preset()
	
	backgrounds.do_auto_scroll = true
	backgrounds.update_background(
		preset[0], 
		preset[1], 
		Rect2(0, 0, 24, 14), 
		preset[3],
		preset[2],
		SCROLL_SPEED
	)


func get_random_preset() -> Array:
	randomize()
	
	var star_coin_percentage: float = current_star_coins/total_star_coins
	var max_index = round(BACKGROUNDS.size() * star_coin_percentage)
	var index = round(rand_range(0, max_index - 1))
	
	return BACKGROUNDS[index]
