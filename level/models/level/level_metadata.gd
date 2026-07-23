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
var level_version : int = 0

var collectible_data: CollectibleData


func _init(set_name: String = DEFAULT_NAME, set_author: String = DEFAULT_AUTHOR, set_description: String = DEFAULT_DESCRIPTION, set_url: String = DEFAULT_THUMBNAIL_URL, set_sky: int = DEFAULT_THUMBNAIL_SKY, set_background: int = DEFAULT_THUMBNAIL_BACKGROUND, set_background_palette: int = DEFAULT_THUMBNAIL_BACKGROUND_PALETTE, set_level_version : int = 100, s_collectible_data: CollectibleData = CollectibleData.new()):
	level_name = set_name
	level_author = set_author
	level_description = set_description
	level_thumbnail_url = set_url
	level_thumbnail_sky = set_sky
	level_thumbnail_background = set_background
	level_thumbnail_background_palette = set_background_palette
	level_version = set_level_version
	
	collectible_data = s_collectible_data


func get_level_background_texture() -> StreamTexture:
	var background_resource = CurrentLevelData.get_cached_background(level_thumbnail_sky)
	return background_resource.texture
	
func get_level_background_modulate() -> Color:
	var background_resource = CurrentLevelData.get_cached_background(level_thumbnail_sky)
	return background_resource.parallax_modulate

func get_level_foreground_texture() -> StreamTexture:
	var foreground_resource = CurrentLevelData.get_cached_foreground(level_thumbnail_background)
	var palette = level_thumbnail_background_palette
	
	if palette == 0:
		return foreground_resource.preview
	else:
		return foreground_resource.palettes[palette - 1]
