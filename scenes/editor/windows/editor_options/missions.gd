extends HBoxContainer

onready var mission_button_container = $"%MissionButtonContainer"
onready var shine_name = $"%ShineName"
onready var shine_description = $"%ShineDescription"
onready var shine_sort_order = $"%SortOrder"
onready var shine_color = $"%Color"
onready var shine_force_leave = $"%ForceLeave"
onready var spawn_area_id = $"%SpawnArea"
onready var spawn_teleporter_tag = $"%TeleporterTag"
onready var mission_show_in_menu = $"%ShowInMenu"
onready var new_mission = $"%NewMission"
onready var erase = $"%Erase"

onready var editor: Editor = get_tree().current_scene

var mission_data: Array
var selected_mission: MissionData

func _ready():
	yield(editor, "ready")
	
	mission_data = CurrentLevelData.level_metadata.collectible_data.mission_data
	refresh_buttons()
		
	on_mission_selected(mission_data[0])
	
	new_mission.connect("button_down", self, "on_new_mission_pressed")
	if mission_data.size() == 1: erase.disabled = true
		
func on_mission_selected(mission: MissionData):
	
	shine_name.load_property(editor, mission["shine_name"], [
		"shine_name",
		TYPE_STRING,
		PropertyInfo.new(shine_name.hint_tooltip)
	], "Shine Name")
	connect_signals(shine_name)
	
	shine_description.load_property(editor, mission["shine_description"], [
		"shine_description",
		TYPE_STRING,
		PropertyInfo.new(shine_description.hint_tooltip)
	], "Shine Description")
	connect_signals(shine_description)
	
	shine_sort_order.load_property(editor, mission["shine_sort_order"], [
		"shine_sort_order",
		TYPE_INT,
		PropertyInfo.new(shine_sort_order.hint_tooltip)
	], "Sort Order")
	connect_signals(shine_sort_order)
	
	shine_color.load_property(editor, mission["shine_color"], [
		"shine_color",
		TYPE_COLOR,
		PropertyInfo.new(shine_color.hint_tooltip)
	], "Shine Color")
	connect_signals(shine_color)
	
	shine_force_leave.load_property(editor, mission["shine_force_leave"], [
		"shine_force_leave",
		TYPE_BOOL,
		PropertyInfo.new(shine_force_leave.hint_tooltip)
	], "Kickout")
	connect_signals(shine_force_leave)
	
	spawn_area_id.load_property(editor, mission["spawn_area_id"], [
		"spawn_area_id",
		[CurrentLevelData, "get_area_args"]
	], "Spawn Area ID")
	connect_signals(spawn_area_id)
	
	spawn_teleporter_tag.load_property(editor, mission["spawn_teleporter_tag"], [
		"spawn_teleporter_tag",
		TYPE_STRING,
		PropertyInfo.new(spawn_teleporter_tag.hint_tooltip)
	], "Spawn Teleporter Tag")
	connect_signals(spawn_teleporter_tag)
	
	mission_show_in_menu.load_property(editor, mission["mission_show_in_menu"], [
		"mission_show_in_menu",
		TYPE_BOOL,
		PropertyInfo.new(mission_show_in_menu.hint_tooltip)
	], "Show in Menu")
	connect_signals(mission_show_in_menu)
	
	selected_mission = mission
	
func connect_signals(property_editor: PropertyEditor):
	if !property_editor.is_connected("property_edited", self, "change_property"):
		property_editor.connect("property_edited", self, "change_property")

func change_property(key: String, value, check_matches):
	selected_mission[key] = value
	if key == "shine_name":
		refresh_buttons()

func refresh_buttons():
	for child in mission_button_container.get_children():
		if child != new_mission: child.queue_free()
	for mission in mission_data:
		mission = mission as MissionData
		
		var button_sound := ButtonSound.new()
		button_sound.text = mission.shine_name
		button_sound.hint_tooltip = button_sound.text
		button_sound.clip_text = true
		
		button_sound.connect("button_down", self, "on_mission_selected", [mission])
		mission_button_container.add_child(button_sound)

func on_new_mission_pressed():
	var new_mission_data := MissionData.new()
	CurrentLevelData.level_metadata.collectible_data.mission_data.append(new_mission_data)
	on_mission_selected(new_mission_data)
	refresh_buttons()
	erase.disabled = false
	
func erase_mission():
	if mission_data.size() == 1: return
	mission_data.erase(selected_mission)
	on_mission_selected(mission_data[0])
	refresh_buttons()
	if mission_data.size() == 1: erase.disabled = true
