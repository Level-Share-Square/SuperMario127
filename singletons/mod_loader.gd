extends Node
## Loads the active mod resource pack on boot and exposes its state.

const ACTIVE_MOD_FILE: String = "user://mods/active.127mod"

var active: bool = false
var path: String = ""


func _init() -> void:
	var file: File = File.new()
	var error: int = file.open(ACTIVE_MOD_FILE, File.READ)
	if error == OK:
		path = file.get_line()
		file.close()
		active = ProjectSettings.load_resource_pack(path)
