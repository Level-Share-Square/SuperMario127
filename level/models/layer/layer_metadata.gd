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


func _init(set_parallax_distance, set_autoset_tint, set_layer_tint, set_order, set_is_ground, set_activated_mission_id):
	parallax_distance = set_parallax_distance
	autoset_tint = set_autoset_tint
	layer_tint = set_layer_tint
	order = set_order
	is_ground = set_is_ground
	activated_mission_id = set_activated_mission_id
