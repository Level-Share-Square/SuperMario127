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
		push_error("Error loading config file!")


func load_setting(section: String, key: String, default):
	return config.get_value(section, key, default)


func change_setting(section: String, key: String, value):
	config.set_value(section, key, value)
	config.save(FILE_PATH)
	
	emit_signal("setting_changed", key, value)
