class_name AreaHeader
extends Resource

# holds the code for the entire area, so that an area can be loaded with just its metadata 
var name: String = ""
var bounds: Rect2 = Rect2(0, 0, 80, 30)

var sky: int = 1
var background: int = 1
var background_palette: int = 0
var bg_autoscroll_speed: float = 0.0

# can hold either the ID for music in the files or a link to custom music
var music = 1
var underwater_music: String = ""

var gravity: float = 7.82
var timer: float = 0.00

var area_code: String = ""


func _init(set_area_code, set_bounds, set_name, set_sky, set_background, set_background_palette, set_bg_autoscroll_speed, set_gravity, set_timer, set_music, set_underwater_music):
	area_code = set_area_code
	bounds = set_bounds
	name = set_name
	sky = set_sky
	background = set_background
	background_palette = set_background_palette
	bg_autoscroll_speed = set_bg_autoscroll_speed
	gravity = set_gravity
	timer = set_timer
	music = set_music
	underwater_music = set_underwater_music
