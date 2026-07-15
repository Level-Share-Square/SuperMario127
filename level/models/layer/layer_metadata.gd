class_name LayerMetadata
extends LevelDataResource


# "distance" from the g layer, affects scroll speed
var parallax_distance: float = 0
var autoset_tint: bool = true
var layer_tint: Color = Color.white

var order: int
var is_ground: bool
# empty means always activated unless disabled is set to true
var activated_mission_ids: PoolIntArray = PoolIntArray()
# for if a layer to be permanently hidden, if this is true
# it should be stripped from the final exported level code for LSS
var disabled: bool = false


func _init(
		set_parallax_distance: float = 0, 
		set_autoset_tint: bool = true, 
		set_layer_tint: Color = Color.white, 
		set_order: int = 0, 
		set_is_ground: bool = true, 
		set_activated_mission_ids: PoolIntArray = PoolIntArray(),
		set_disabled: bool = false
	):
	parallax_distance = set_parallax_distance
	autoset_tint = set_autoset_tint
	layer_tint = set_layer_tint
	order = set_order
	is_ground = set_is_ground
	activated_mission_ids = set_activated_mission_ids
	disabled = set_disabled
