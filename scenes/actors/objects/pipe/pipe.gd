extends GameObject

onready var area = $Area2D
var activated = false

var area_id := 0

func _set_properties():
	savable_properties = ["area_id"]
	editable_properties = ["area_id"]
	
func _set_property_values():
	set_property("area_id", area_id, true)

func enter(body):
	if CurrentLevelData.level_data.areas.size() > area_id and enabled and !activated and body.name.begins_with("Character") and body.controllable:
		var player = get_tree().get_current_scene()
		CurrentLevelData.area = area_id
		player.reload_scene()

func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "enter")
