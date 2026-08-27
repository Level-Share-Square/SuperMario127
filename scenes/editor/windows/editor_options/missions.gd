extends HBoxContainer

onready var mission_button_container = $"%MissionButtonContainer"
onready var globals = $"%Globals"
onready var new_mission = $"%NewMission"
onready var erase = $"%Erase"
onready var mission_container = $"%MissionContainer"
onready var globals_container = $"%GlobalsContainer"
onready var linear_progression = $"%LinearProgression"
onready var persistent_nozzles = $"%PersistentNozzles"
onready var mission_prefab = $"%MissionPrefab"

onready var editor: Editor = get_tree().current_scene

var mission_data: Array
var selected_mission: MissionData
var collectible_data: CollectibleData

signal collectible_data_changed(key, new_value)

func _ready():
	yield(editor, "ready")
	
	mission_data = CurrentLevelData.level_metadata.collectible_data.mission_data
	collectible_data = CurrentLevelData.level_metadata.collectible_data
	refresh_buttons()
	
	if mission_data.size() > 0:
		on_mission_selected(mission_data[0])
	else:
		mission_container.hide()
	
	linear_progression.load_property(editor, collectible_data["linear_progression"], [
		"linear_progression",
		TYPE_BOOL,
		PropertyInfo.new(linear_progression.hint_tooltip)
	])
	connect_global_signals(linear_progression)
	
	var nozzle_array := PoolStringArray(collectible_data["persistent_nozzles"])
	persistent_nozzles.load_property(persistent_nozzles, nozzle_array, [
		"persistent_nozzles",
		[self, "get_nozzle_args"],
		PropertyInfo.new(persistent_nozzles.hint_tooltip)
	])
	connect_global_signals(persistent_nozzles)
	
	globals.connect("pressed", self, "on_globals_pressed")
	new_mission.connect("pressed", self, "on_new_mission_pressed")
	mission_prefab.erase.connect("pressed", self, "erase_mission")
	CurrentLevelData.level_metadata.collectible_data.connect("data_changed", self, "update_mission")

func on_mission_selected(mission: MissionData):
	mission_container.show()
	globals_container.hide()
	
	mission_prefab.load_properties(self, mission)
	
	selected_mission = mission
	
func update_mission(mission):
	refresh_buttons()
	on_mission_selected(mission)

func change_property(key: String, value, check_matches, save_to_data):
	var old_val = selected_mission[key]
	
	selected_mission[key] = value
	if key == "shine_name":
		refresh_buttons()
		
	if old_val == value: return
	set_block_signals(true)
	CurrentLevelData.level_metadata.collectible_data.emit_signal("data_changed", selected_mission)
	set_block_signals(false)

func connect_global_signals(property_editor: PropertyEditor):
	if !property_editor.is_connected("property_edited", self, "change_global_property"):
		property_editor.connect("property_edited", self, "change_global_property")
	if !is_connected("collectible_data_changed", property_editor, "property_changed"):
		connect("collectible_data_changed", property_editor, "property_changed")

func change_global_property(key: String, value, check_matches, save_to_data):
	collectible_data[key] = value
	emit_signal("collectible_data_changed", key, value)

func refresh_buttons():
	for child in mission_button_container.get_children():
		if child != new_mission and child != globals: child.queue_free()
	for mission in mission_data:
		mission = mission as MissionData
		
		var button_sound := ButtonSound.new()
		button_sound.text = mission.shine_name
		button_sound.hint_tooltip = button_sound.text
		button_sound.clip_text = true
		button_sound.focus_mode = Control.FOCUS_NONE
		
		button_sound.connect("pressed", self, "on_mission_selected", [mission])
		mission_button_container.add_child(button_sound)

func on_new_mission_pressed():
	var new_mission_data := MissionData.new()
	CurrentLevelData.level_metadata.collectible_data.mission_data.append(new_mission_data)
	on_mission_selected(new_mission_data)
	refresh_buttons()
	mission_container.show()
	globals_container.hide()
	
func erase_mission():
	mission_data.erase(selected_mission)
	if mission_data.size() > 0:
		on_mission_selected(mission_data[0])
	else:
		mission_container.hide()
	refresh_buttons()

func on_globals_pressed():
	mission_container.hide()
	globals_container.show()

func get_nozzle_args() -> Dictionary:
	var args: Dictionary = {
		"HoverNozzle": "Hover",
		"RocketNozzle": "Rocket",
		"TurboNozzle": "Turbo"
	}
	return args
