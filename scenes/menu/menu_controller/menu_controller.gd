extends Node2D

## TEMP
export var mode: int = 2

onready var backgrounds: Node2D = $Backgrounds

var possible_backgrounds: Array = [
	7,
]
var possible_parallax: Array = [
	21,
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var picked_background: int = possible_backgrounds[0]
	var picked_parallax: int = possible_parallax[0]
	var extra_offset: int = 65
	
	backgrounds.update_background(picked_background, picked_parallax, Rect2(0, 0, 24, 14), extra_offset, 0)
	backgrounds.do_auto_scroll = true
	
	print("B")
	Singleton.Music.stop_temporary_music()
	Singleton.Music.change_song(Singleton.Music.last_song, 31) # temporary, should add a way for screens to define their own music setting later
	Singleton.Music.last_song = 31
