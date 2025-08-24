class_name LevelMetadata
extends Resource


const DEFAULT_NAME: String = "My Level"
const DEFAULT_AUTHOR: String = "Unknown"
const DEFAULT_DESCRIPTION: String = "This level has no description."
const DEFAULT_THUMBNAIL_URL: String = ""
 
const current_format_version := "0.5.5"

var level_name := DEFAULT_NAME
var level_author := DEFAULT_AUTHOR
var level_description := DEFAULT_DESCRIPTION
var level_thumbnail_url := DEFAULT_THUMBNAIL_URL


func _init(set_name: String, set_author: String, set_description: String, set_url: String):
	level_name = set_name
	level_author = set_author
	level_description = set_description
	level_thumbnail_url = set_url
