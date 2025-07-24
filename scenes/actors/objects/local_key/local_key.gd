extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var animation_player = $AnimationPlayer

var id: String
var color: Color

func _set_properties():
	savable_properties = ["id", "color"]
	editable_properties = ["id", "color"]

func _set_property_values():
	set_property("id", id)
	set_property("color", color)

func collect(body):
	if enabled and body.name.begins_with("Character") and !body.dead:
		Singleton.CurrentLevelData.level_data.vars.collect_local_key(id)
		#add animation here
		
func _ready():
	var _connect = area.connect("body_entered", self, "collect")
