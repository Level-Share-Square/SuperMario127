extends CanvasLayer


onready var timer = $Timer
onready var current_mod = $VBoxContainer/CurrentMod


func _ready():
	OS.current_screen = 0
	
	if ModLoader.active:
		current_mod.text = "Current Mod: " + ModLoader.path.get_file().get_basename()
		yield(timer, "timeout")
	
	Singleton.SceneSwitcher.menu_return_screen = "Converter"
	Singleton.SceneSwitcher.quit_to_menu()


func reset_mod():
	timer.stop()
	
	var directory := Directory.new()
	directory.remove("user://mods/active.127mod")
	
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit(0)
