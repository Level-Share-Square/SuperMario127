extends VBoxContainer

export var erase_disabled: bool = false

onready var editor = get_tree().current_scene
onready var shine_name = $"%ShineName"
onready var shine_description = $"%ShineDescription"
onready var shine_sort_order = $"%SortOrder"
onready var shine_color = $"%Color"
onready var shine_force_leave = $"%ForceLeave"
onready var spawn_area_id = $"%SpawnArea"
onready var spawn_teleporter_tag = $"%TeleporterTag"
onready var mission_show_in_menu = $"%ShowInMenu"
onready var erase = $"Erase"

func _ready():
	if erase_disabled: erase.hide()

func load_properties(to: Node, mission: MissionData):
	shine_name.load_property(editor, mission["shine_name"], [
		"shine_name",
		TYPE_STRING,
		PropertyInfo.new(shine_name.hint_tooltip)
	], "Shine Name")
	connect_signals(shine_name, to)
	
	shine_description.load_property(editor, mission["shine_description"], [
		"shine_description",
		TYPE_STRING,
		PropertyInfo.new(shine_description.hint_tooltip)
	], "Shine Description")
	connect_signals(shine_description, to)
	
	shine_sort_order.load_property(editor, mission["shine_sort_order"], [
		"shine_sort_order",
		TYPE_INT,
		PropertyInfo.new(shine_sort_order.hint_tooltip)
	], "Sort Order")
	connect_signals(shine_sort_order, to)
	
	shine_color.load_property(editor, mission["shine_color"], [
		"shine_color",
		TYPE_COLOR,
		PropertyInfo.new(shine_color.hint_tooltip)
	], "Shine Color")
	connect_signals(shine_color, to)
	
	shine_force_leave.load_property(editor, mission["shine_force_leave"], [
		"shine_force_leave",
		TYPE_BOOL,
		PropertyInfo.new(shine_force_leave.hint_tooltip)
	], "Kickout")
	connect_signals(shine_force_leave, to)
	
	spawn_area_id.load_property(editor, mission["spawn_area_id"], [
		"spawn_area_id",
		[CurrentLevelData, "get_area_args"]
	], "Spawn Area ID")
	connect_signals(spawn_area_id, to)
	
	spawn_teleporter_tag.load_property(editor, mission["spawn_teleporter_tag"], [
		"spawn_teleporter_tag",
		TYPE_STRING,
		PropertyInfo.new(spawn_teleporter_tag.hint_tooltip)
	], "Spawn Teleporter Tag")
	connect_signals(spawn_teleporter_tag, to)
	
	mission_show_in_menu.load_property(editor, mission["mission_show_in_menu"], [
		"mission_show_in_menu",
		TYPE_BOOL,
		PropertyInfo.new(mission_show_in_menu.hint_tooltip)
	], "Show in Menu")
	connect_signals(mission_show_in_menu, to)
	

func connect_signals(property_editor: PropertyEditor, to: Node):
	if !property_editor.is_connected("property_edited", to, "change_property"):
		property_editor.connect("property_edited", to, "change_property")
