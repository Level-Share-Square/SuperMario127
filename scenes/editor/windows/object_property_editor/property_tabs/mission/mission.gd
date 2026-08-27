extends PropertyTab

onready var mission_prefab = $"%MissionPrefab"
onready var scroll_container = $"%ScrollContainer"
onready var no_mission = $"%NoMission"
onready var mission = $"%Mission"
onready var add_mission = $"%AddMission"

var selected_mission: MissionData

func _ready():
	var object = objects.keys()[0]
	object.connect("property_changed", self, "on_property_changed")
	
	if objects.size() > 1:
		for var_object in objects:
			if var_object.mission_uuid != object.mission_uuid:
				no_mission.text = "Various missions selected!"
				scroll_container.hide()
				mission.hide()
				add_mission.hide()
				no_mission.show()
				
				CurrentLevelData.level_metadata.collectible_data.connect("data_changed", self, "update_mission")
				return
	
	if not object.mission_uuid or object.mission_uuid == "":
		scroll_container.hide()
		no_mission.show()
		load_mission_property(object, "")
	else:
		
		scroll_container.show()
		no_mission.hide()
		load_mission_property(object, object.mission_uuid)
		
		selected_mission = CurrentLevelData.level_metadata.collectible_data.get_mission_by_uuid(object.mission_uuid)
		mission_prefab.load_properties(self, selected_mission)
		
	CurrentLevelData.level_metadata.collectible_data.connect("data_changed", self, "update_mission")
	
func update_mission(mission):
	if mission == selected_mission:
		mission_prefab.load_properties(self, selected_mission)
		self.mission.property_changed("mission_uuid", selected_mission.mission_uuid)
		on_property_changed("mission_uuid", selected_mission.mission_uuid)

func load_properties(_editor, _objects):
	editor = _editor
	objects = _objects

func on_property_changed(key, value):
	if key == "mission_uuid":
		selected_mission = CurrentLevelData.level_metadata.collectible_data.get_mission_by_uuid(value)
		mission_prefab.load_properties(self, selected_mission)
		
		scroll_container.show()
		no_mission.hide()

func change_property(property: String, new_value, check_matches, save_to_data):
	if property == "mission_uuid": .change_property(property, new_value, check_matches, save_to_data)
	
	var old_val = selected_mission[property]
	selected_mission[property] = new_value
	
	if old_val == new_value: return
	
	
	mission.property_changed("mission_uuid", selected_mission.mission_uuid)
	
	set_block_signals(true)
	CurrentLevelData.level_metadata.collectible_data.emit_signal("data_changed", selected_mission)
	set_block_signals(false)

func load_mission_property(object, init_val):
	mission.load_property(editor, init_val, [
		"mission_uuid",
		[object, "get_mission_args"],
		PropertyInfo.new(mission.hint_tooltip)
	], "Mission")
	connect_signals(mission)


func add_mission():
	var new_mission_data := MissionData.new()
	CurrentLevelData.level_metadata.collectible_data.mission_data.append(new_mission_data)
	selected_mission = new_mission_data
	CurrentLevelData.level_metadata.collectible_data.emit_signal("data_changed", new_mission_data)
