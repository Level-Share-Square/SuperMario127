extends Node

const CATEGORIES = [
	"General",
	"Meta"
]

func _init():
	var config: ConfigFile = LocalSettings.config
	
	LocalSettings.connect("setting_changed", self, "change_setting")
	for category in CATEGORIES:
		if config.has_section(category):
			load_category(category, config)
	
	# we can initialize this here for now i suppose
	if not config.has_section_key("Meta", "game_version"):
		LocalSettings.change_setting("Meta", "game_version", Singleton.PlayerSettings.game_version)
		handle_version_upgrade()

func load_category(category: String, config: ConfigFile):
	for key in config.get_section_keys(category):
		if config.has_section_key(category, key):
			change_setting(
				key, LocalSettings.load_setting(category, key, null)
			)



func change_setting(key: String, new_value):
	match key:
		# General
		"window_scale":
			ScreenSizeUtil.set_screen_size(new_value)
			if not OS.window_fullscreen:
				last_non_full_scale = new_value
		
		"v_sync":
			OS.vsync_enabled = new_value
		"fps_cap":
			Engine.target_fps = 10 * (new_value + 3)
		"show_timer":
			Singleton.TimeScore.shown = new_value
		"rich_presence":
			Singleton2.rp = new_value
		"level_ghost":
			Singleton2.ghost_enabled = new_value
		"dark_mode":
			Singleton2.dark_mode = new_value
			Singleton2.toggle_dark_mode()
		"multiplayer":
			Singleton.PlayerSettings.number_of_players = 2 if new_value else 1
		"first_player":
			Singleton.PlayerSettings.player1_character = new_value
		"second_player":
			Singleton.PlayerSettings.player2_character = new_value
		
		"master_volume":
			var bus_index: int = AudioServer.get_bus_index("Master")
			var volume_db: float = linear2db(float(new_value) / 100)
			AudioServer.set_bus_volume_db(bus_index, volume_db)
			last_master_volume = new_value

		"bgm_volume":
			var bus_index: int = AudioServer.get_bus_index("Music")
			var volume_db: float = linear2db(float(new_value) / 100)
			AudioServer.set_bus_volume_db(bus_index, volume_db)
			if new_value > 0: last_non_muted_bgm = new_value

		"sfx_volume":
			var bus_index: int = AudioServer.get_bus_index("Sounds")
			var volume_db: float = linear2db(float(new_value) / 100)
			AudioServer.set_bus_volume_db(bus_index, volume_db)
		
		# Meta
		"game_version":
			if new_value != Singleton.PlayerSettings.game_version:
				handle_version_upgrade()


## related to various hotkeys
var last_master_volume: float = 75
var last_non_muted_bgm: float = 100
var last_non_full_scale: int = 0

func _unhandled_input(event):
	if event.is_action_pressed("fullscreen"):
		LocalSettings.change_setting("General", "window_scale", 3 if not OS.window_fullscreen else last_non_full_scale)

	if event.is_action_pressed("volume_up"):
		LocalSettings.change_setting("General", "master_volume", last_master_volume + 5)
	if event.is_action_pressed("volume_down"):
		LocalSettings.change_setting("General", "master_volume", last_master_volume - 5)
	
	if event.is_action_pressed("mute"):
		var current_vol = LocalSettings.load_setting("General", "bgm_volume", 100)
		LocalSettings.change_setting("General", "bgm_volume", 0 if current_vol > 0 else last_non_muted_bgm)



## when you come from a version that's lower or higher than your current one
func handle_version_upgrade():
	print("Version mismatch! This currently does not do anything...")
