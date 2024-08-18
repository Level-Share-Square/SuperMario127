extends Node

export var vbox_container_path: NodePath
onready var vbox_container = get_node(vbox_container_path)

export var grid_container_path: NodePath
onready var grid_container = get_node(grid_container_path)

func _ready():
	for setting in (grid_container.get_children() + vbox_container.get_children()):
		change_setting(
			setting.setting_key, LocalSettings.load_setting(
				setting.setting_section, 
				setting.setting_key,
				setting.default_value
			)
		)
	LocalSettings.connect("setting_changed", self, "change_setting")

func change_setting(key: String, new_value):
	match key:
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

		"bgm_volume":
			var bus_index: int = AudioServer.get_bus_index("Music")
			var volume_db: float = linear2db(float(new_value) / 100)
			AudioServer.set_bus_volume_db(bus_index, volume_db)

		"sfx_volume":
			var bus_index: int = AudioServer.get_bus_index("Sounds")
			var volume_db: float = linear2db(float(new_value) / 100)
			AudioServer.set_bus_volume_db(bus_index, volume_db)


# fullscreen and volume hotkeys
export var master_volume_path: NodePath
onready var master_volume_slider: HSlider = get_node(master_volume_path).get_node("Panel/HSlider")

var last_non_full_scale: int = 0
func _input(event):
	if event.is_action_pressed("fullscreen"):
		LocalSettings.change_setting("General", "window_scale", 3 if not OS.window_fullscreen else last_non_full_scale)

	if Input.is_action_just_pressed("volume_up"):
		master_volume_slider.value += 5
	if Input.is_action_just_pressed("volume_down"):
		master_volume_slider.value -= 5
