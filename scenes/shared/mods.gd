extends Control

onready var button : OptionButton = $Box

var dir = Directory.new()
var file = File.new()

var mod_array = []

var value : bool = false

func _ready():
	var filing = File.new()
	button.add_item("No Mod Selected")
	for i in list_files_in_directory("user://mods"):
		print(i)
		if i != "":
			mod_array.append(i)
			button.add_item(i)
	filing.open("user://mods/active.127mod", filing.READ)
	var mod = filing.get_line()
	filing.close()
	print(mod)
	if mod != "":
		var one = mod.replace("user://mods/", "")
		var two = mod_array.find(one)
		print(mod_array)
		print([one, two])
		button.select(two + 1)
	var _connect = button.connect("item_selected", self, "is_item_selected")

func is_item_selected(index):
	if index == 0:
		return
	file.open("user://mods/active.127mod", file.WRITE)
	file.store_line("user://mods/" + mod_array[index - 1])
	file.close()
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit(0)

#func get_all_files():
#	var files = []
#	var directories = Directory.new()
#	directories.open("res://")
#	directories.list_dir_begin()
#	var folders = []
#	var folders_passed = 0
#
#	while true:
#		var file = directories.get_next()
#		print(file)
#		if directories.current_is_dir(): folders.append(file)
#		if file is Image: files.append(file)
#		if file == "":
#			if folders_passed < folders.size() - 1:
#				directories.list_dir_end()
#				directories.open("res://" + folders[folders_passed])
#				directories.list_dir_begin()
#				folders_passed += 1
#			else: break
#	directories.list_dir_end()
#	for i in files:
#		ResourceLoader.load()

func list_files_in_directory(path):
	var files = []
	dir.open(path)
	dir.list_dir_begin(true)
	var file

	while file != "":
		file = dir.get_next()
		if file != "active.127mod":
			if (".pck" in file) || (".zip" in file):
				files.append(file)

	dir.list_dir_end()

	return files
