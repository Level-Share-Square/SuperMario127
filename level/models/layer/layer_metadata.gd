class_name LayerMetadata
extends Resource


# "distance" from the g layer, affects scroll speed
var parallax_distance: int 
var autoset_tint: bool
var layer_tint: Color

var order: int
var is_ground: bool
# -1 means always activated
var activated_mission_id: int = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
