class_name TileMapLayer
extends TileMap


const BackgroundColor = Color(0.54, 0.54, 0.54)

export(LevelShared.TileLayers) var layer = 0
export var background = false

var transparent = false
var hidden = false
var color: Color = Color.white
var target_alpha = 1.0
var z_layer: int = 0


func _ready():
	z_layer = layer + LevelShared.layer_index_offset
	z_index = z_layer * LevelShared.layer_spacing if layer != 2 else z_layer * LevelShared.layer_spacing + 2
	
	if background:
		color = Color(BackgroundColor, 1.0)
	else:
		color = Color(Color.white, 1.0)


func _process(delta):
	if hidden:
		modulate.a = .25
		return
	
	if transparent:
		modulate = modulate.linear_interpolate(Color(0, 0, 0, .25), interp_weight_idp(10.0, delta))
	else:
		modulate = modulate.linear_interpolate(color, interp_weight_idp(10.0, delta))


func interp_weight_idp(weight : float, delta : float) -> float:
	return 1 - exp(-weight * delta)
