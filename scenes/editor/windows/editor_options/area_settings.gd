extends Control

onready var editor = owner.owner
onready var shared = editor.get_node("%Shared")
onready var camera = editor.get_node("%EditorCamera")

onready var size_x = $"%SizeX"
onready var size_y = $"%SizeY"
onready var gravity = $"%Gravity"
onready var mins = $"%Mins"
onready var sec = $"%Sec"


func _ready():
	var alterables: Array = [size_x, size_y, gravity, mins, sec]
	load_settings()
	for value in alterables:
		value.connect("value_changed", self, "value_changed", [value])
	
func load_settings():
	var settings = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings
	size_x.value = settings.bounds.size.x
	size_y.value = settings.bounds.size.y
	gravity.value = settings.gravity
	mins.value = int(settings.timer/60)
	sec.value = fmod(settings.timer, 60.0) 

func value_changed(value, changed_value):
	var area =  Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area]
	var settings = area.settings
	
	settings.bounds.size.x = size_x.value
	settings.bounds.size.y = size_y.value
	settings.gravity = gravity.value
	settings.timer = mins.value*60 + sec.value
	if "Size" in changed_value.name:
		shared.update_tilemaps()
		camera.update_limits(area)
