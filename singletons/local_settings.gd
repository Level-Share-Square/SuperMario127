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


func load_setting(section: String, key: String, default):
	var err = config.load(FILE_PATH)

	if err == OK:
		return config.get_value(section, key, default)

	push_error("Error loading config file!")

	return null


func change_setting(section: String, key: String, value):
	config.set_value(section, key, value)
	config.save(FILE_PATH)
	
	emit_signal("setting_changed", key, value)
