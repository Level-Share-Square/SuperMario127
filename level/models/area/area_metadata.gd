class_name AreaHeader
extends LevelDataResource

const DEFAULT_AREA_BOUNDS: Rect2 = Rect2(0, 0, 80, 30)
const DEFAULT_AREA_NAME: String = ""
const DEFAULT_AREA_SKY: int = 0
const DEFAULT_AREA_BACKGROUND: int = 0
const DEFAULT_AREA_BACKGROUND_PALETTE: int = 0
const DEFAULT_BG_AUTOSCROLL_SPEED: float = 0.0 
const DEFAULT_MUSIC: int = 0
const DEFAULT_GRAVITY: float = 7.82
const DEFAULT_TIMER: float = 0.0 

var name: String
var bounds: Rect2

var sky: int
var background: int
var background_palette: int
var bg_autoscroll_speed: float

# can hold either the ID for music in the files or a link to custom music
var music
var underwater_music: String

var gravity: float
var timer: float
# holds the code for the entire area, so that an area can be loaded with just its metadata 
var area_code: String


func _init(set_area_code = "", set_bounds = DEFAULT_AREA_BOUNDS, set_name = DEFAULT_AREA_NAME, set_sky = DEFAULT_AREA_SKY, set_background = DEFAULT_AREA_BACKGROUND, set_background_palette = DEFAULT_AREA_BACKGROUND_PALETTE, set_bg_autoscroll_speed = DEFAULT_BG_AUTOSCROLL_SPEED, set_gravity = DEFAULT_GRAVITY, set_timer = DEFAULT_TIMER, set_music = DEFAULT_MUSIC, set_underwater_music = ""):
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
