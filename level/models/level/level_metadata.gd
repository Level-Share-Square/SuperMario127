class_name LevelMetadata
extends LevelDataResource


# todo: move these consts to the place where the "create new level" function will be

const DEFAULT_NAME: String = "My Level"
const DEFAULT_AUTHOR: String = "Unknown"
const DEFAULT_DESCRIPTION: String = "This level has no description."
const DEFAULT_THUMBNAIL_URL: String = ""
const DEFAULT_THUMBNAIL_SKY: int = 0
const DEFAULT_THUMBNAIL_BACKGROUND: int = 0
const DEFAULT_THUMBNAIL_BACKGROUND_PALETTE: int = 0
const current_format_version := "0.5.5"

var level_name := DEFAULT_NAME
var level_author := DEFAULT_AUTHOR
var level_description := DEFAULT_DESCRIPTION
var level_thumbnail_url := DEFAULT_THUMBNAIL_URL
var level_thumbnail_sky : int = DEFAULT_THUMBNAIL_SKY
var level_thumbnail_background : int = DEFAULT_THUMBNAIL_BACKGROUND
var level_thumbnail_background_palette : int = DEFAULT_THUMBNAIL_BACKGROUND_PALETTE


func _init(set_name: String, set_author: String, set_description: String, set_url: String, set_sky: int, set_background: int, set_background_palette: int):
	level_name = set_name
	level_author = set_author
	level_description = set_description
	level_thumbnail_url = set_url
	level_thumbnail_sky = set_sky
	level_thumbnail_background = set_background
	level_thumbnail_background_palette = set_background_palette
