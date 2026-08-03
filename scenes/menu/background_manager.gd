extends Node2D


onready var backgrounds = $Backgrounds

const BG_ID: int = 1
const PARALLAX_ID: int = 13
const PARALLAX_PALETTE: int = 0
const PARALLAX_OFFSET: int = 65
const SCROLL_SPEED: float = 300.0

const BACKGROUNDS := [
	[1, 13, 0, 64],
	[2, 1, 0, 160],
	[4, 8, 0, 96],
	[8, 18, 0, 260],
	[7, 21, 0, 64],
	[10, 1, 1, 160],
	[6, 20, 5, 72]
]

var current_star_coins: int = 0
var total_star_coins: int = 100


func _ready():
	## the backgrounds should differ in 1.0, but for 0.10.0 it will be fixed like previous updates
	var preset = BACKGROUNDS[6] #get_random_preset()
	
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
	var max_index = round((BACKGROUNDS.size() - 1) * star_coin_percentage)
	var index = round(rand_range(0, max_index))
	
	return BACKGROUNDS[index]
