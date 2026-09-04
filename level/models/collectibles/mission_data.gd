class_name MissionData
extends LevelDataResource


var mission_uuid: String
var mission_show_in_menu: bool

var shine_name: String
var shine_description: String
var shine_sort_order: int
var shine_color: Color
var shine_force_leave: bool

var spawn_area_id: int
var spawn_teleporter_tag: String


func _init(
		s_mission_uuid: String = uuid_util.v4(),
		s_mission_show_in_menu: bool = true,
		s_shine_name: String = "Unnamed Shine", 
		s_shine_description: String = "", 
		s_shine_sort_order: int = 0,
		s_shine_color: Color = Color.yellow,
		s_shine_force_leave: bool = true,
		s_spawn_area_id: int = 0,
		s_spawn_teleporter_tag: String = "spawn"
	):
	mission_uuid = s_mission_uuid
	mission_show_in_menu = s_mission_show_in_menu
	
	shine_name = s_shine_name
	shine_description = s_shine_description
	shine_sort_order = s_shine_sort_order
	shine_color = s_shine_color
	shine_force_leave = s_shine_force_leave
	
	spawn_area_id = s_spawn_area_id
	spawn_teleporter_tag = s_spawn_teleporter_tag

static func sort_by_order(a: MissionData, b: MissionData):
	return a.shine_sort_order < b.shine_sort_order
