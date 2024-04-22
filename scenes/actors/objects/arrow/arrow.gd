extends GameObject

var show_behind_player = true
var color = Color(1, 0, 0)
var moves = false

onready var recolorable = $Recolorable
onready var animationplayer = $AnimationPlayer

func _set_properties():
	savable_properties = ["show_behind_player", "color", "moves"]
	editable_properties = ["show_behind_player", "color", "moves"]

func _set_property_values(): 
	set_property("show_behind_player", show_behind_player, true)
	set_property("color", color, true)
	set_property("moves", moves, true)

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
	if !animationplayer.is_playing() and moves:
		animationplayer.play("move")
	if animationplayer.is_playing() and !moves:
		animationplayer.stop()
