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
const DEFAULT_CUSTOM_MUSIC_NAME: String = "Custom Song"
const DEFAULT_CUSTOM_MUSIC_AUTHOR: String = "Unknown Author"


export var name: String
export var bounds: Rect2
export var show_name: bool = true
export var show_song: bool = true

export var sky: int
export var background: int
export var background_palette: int
export var bg_autoscroll_speed: float

# can hold either the ID for music in the files or a link to custom music
var music
export var underwater_music: String
# for custom music
var custom_music_name: String = "Custom Song"
var custom_music_author: String = "Unknown Author"

export var gravity: float
export var timer: float
export var minimum_timer: float = 15
# holds the code for the entire area, so that an area can be loaded with just its metadata 
export var area_code: String

export var shine_shard_count: int = 0
export var max_purples_count: int = 0


func _init(
	set_area_code = "", 
	set_bounds = DEFAULT_AREA_BOUNDS, 
	set_name = DEFAULT_AREA_NAME, 
	set_sky = DEFAULT_AREA_SKY, 
	set_background = DEFAULT_AREA_BACKGROUND, 
	set_background_palette = DEFAULT_AREA_BACKGROUND_PALETTE, 
	set_bg_autoscroll_speed = DEFAULT_BG_AUTOSCROLL_SPEED, 
	set_gravity = DEFAULT_GRAVITY, 
	set_timer = DEFAULT_TIMER, 
	set_music = DEFAULT_MUSIC, 
	set_underwater_music = "", 
	set_shine_shard_count: int = 0, 
	set_max_purples_count: int = 0,
	set_show_name: bool = true,
	set_custom_music_name: String = DEFAULT_CUSTOM_MUSIC_NAME,
	set_custom_music_author: String = DEFAULT_CUSTOM_MUSIC_AUTHOR,
	set_show_song: bool = true,
	set_minimum_timer: float = 15
):
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
	shine_shard_count = set_shine_shard_count
	max_purples_count = set_max_purples_count
	show_name = set_show_name
	custom_music_name = set_custom_music_name
	custom_music_author = set_custom_music_author
	show_song = set_show_song
	minimum_timer = set_minimum_timer
