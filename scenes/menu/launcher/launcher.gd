extends CanvasLayer


onready var timer = $Timer
onready var current_mod = $VBoxContainer/CurrentMod


func _ready():
	if Singleton2.mod_active:
		current_mod.text = "Current Mod: " + Singleton2.mod_path.get_file().get_basename()
		yield(timer, "timeout")
	
	Singleton.SceneSwitcher.quit_to_menu()


func reset_mod():
	timer.stop()
	
	var directory := Directory.new()
	directory.remove("user://mods/active.127mod")
	
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit(0)
