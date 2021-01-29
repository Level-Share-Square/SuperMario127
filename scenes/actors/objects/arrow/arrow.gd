extends GameObject

var show_behind_player = true
var color = Color(1, 0, 0)

onready var recolorable = $Recolorable

func _set_properties():
	savable_properties = ["show_behind_player", "color"]
	editable_properties = ["show_behind_player", "color"]

func _set_property_values(): 
	set_property("show_behind_player", show_behind_player, true)
	set_property("color", color, true)

func _ready():
	preview_position = Vector2(70, 85)
	if is_preview:
		return
	
	if show_behind_player: 
		z_index = -2
	else:
		z_index = 2

func _process(delta):
	recolorable.modulate = color
