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
	var area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	size_x.value = area.bounds.size.x
	size_y.value = area.bounds.size.y
	gravity.value = area.gravity
	mins.value = int(area.timer/60)
	sec.value = fmod(area.timer, 60.0) 

func value_changed(value, changed_value):
	var area =  CurrentLevelData.level_data.areas[CurrentLevelData.area]

	area.bounds.size.x = size_x.value
	area.bounds.size.y = size_y.value
	area.gravity = gravity.value
	area.timer = mins.value*60 + sec.value
	if "Size" in changed_value.name:
		shared.update_tilemaps()
		camera.update_limits(area)
