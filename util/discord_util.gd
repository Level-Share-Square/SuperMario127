extends Node

const discord_addon = preload("res://gdnative/libdiscord.gdns")
const app_id = 741353019454652436

var discord = discord_addon.new()

func _ready():
	discord.start(app_id)
	discord.start_time = OS.get_unix_time();
	discord.large_image_key = "icon";
	discord.large_image_text = "Super Mario 127";
	pass

func update_editor():
	discord.details = "Editing a Level";
	update_level_name()
	discord.update()
	
func update_level_name():
	discord.state = "Level \"" + CurrentLevelData.level_data.name + "\""

func update_play_mode():
	discord.details = "Playing a Level"
	discord.update()
	
