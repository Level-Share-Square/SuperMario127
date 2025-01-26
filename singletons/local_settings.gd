extends Node
## Settings stored on the user's system.

# this is partially just the script from solar engine
# i backported it to old 127, hope thats ok!!

signal setting_changed(key, new_value)

const FILE_PATH: String = "user://settings.cfg"
var config := ConfigFile.new()

func _init():
	var file := File.new()
	if not file.file_exists(FILE_PATH):
		config.save(FILE_PATH)
	
	# theres only one config file used
	# so i moved the loading to this function
	var err = config.load(FILE_PATH)
	if err != OK:
		printerr("Error loading config file!")


func load_setting(section: String, key: String, default):
	return config.get_value(section, key, default)


func change_setting(section: String, key: String, value):
	config.set_value(section, key, value)
	config.save(FILE_PATH)
	
	emit_signal("setting_changed", key, value)


var last_refresh_rate : float = 60.0

#should this be here? probably not, but I can't think of a better place to shove it
func _update_framerate_to_refresh_rate():
	# stole this from the godot docs, should work like a charm to
	# not unnecessarily have the framerate absurdly high though
	var refresh_rate = OS.get_screen_refresh_rate()
	if refresh_rate < 0:
		refresh_rate = 60.0
	
	if refresh_rate != last_refresh_rate:
		Engine.set_target_fps(refresh_rate)
		last_refresh_rate = refresh_rate
	
	#this was in lss_ping.gd... for some reason. well now at least it's not being called every physics tick
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")
