extends Control

## ughhh get me out of here already

onready var level_name = $MarginContainer/VBoxContainer/HBoxContainer/LevelName
onready var level_author = $MarginContainer/VBoxContainer/HBoxContainer/LevelAuthor
onready var thumbnail_url = $MarginContainer/VBoxContainer/MarginContainer/ThumbnailURL
onready var description = $MarginContainer/VBoxContainer/Description


func switch_to_settings():
	get_parent().get_node("LevelSettings").visible = true
	visible = false
	
	update_vars()
	

func update_vars():
	update_level_name(level_name.text)
	update_level_author(level_author.text)
	update_thumbnail_url(thumbnail_url.text)
	update_description(description.text)


func _ready():
	var _connect = level_name.connect("focus_exited", self, "update_level_name", [level_name.text])
	_connect = level_author.connect("focus_exited", self, "update_level_author", [level_author.text])
	_connect = thumbnail_url.connect("focus_exited", self, "update_thumbnail_url", [thumbnail_url.text])
	_connect = description.connect("focus_exited", self, "update_description", [description.text])
	
	level_name.text = Singleton.CurrentLevelData.level_data.name
	level_author.text = Singleton.CurrentLevelData.level_data.author
	thumbnail_url.text = Singleton.CurrentLevelData.level_data.thumbnail_url
	description.text = Singleton.CurrentLevelData.level_data.description


func update_level_name(new_value: String):
	Singleton.CurrentLevelData.level_data.name = new_value

func update_level_author(new_value: String):
	Singleton.CurrentLevelData.level_data.author = new_value

func update_thumbnail_url(new_value: String):
	Singleton.CurrentLevelData.level_data.thumbnail_url = new_value

func update_description(new_value: String):
	Singleton.CurrentLevelData.level_data.description = new_value

func _input(event):
	if event.is_action_pressed("text_release_focus"):
		level_name.release_focus()
		level_author.release_focus()
		thumbnail_url.release_focus()
	
	if event.is_action_pressed("editor_escape"):
		level_name.release_focus()
		level_author.release_focus()
		thumbnail_url.release_focus()
		description.release_focus()
