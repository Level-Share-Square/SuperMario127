extends TextureButton

onready var icon = $Icon
var margin := 0
var base_margin := 0
var item : PlaceableItem

func _ready():
	margin_left = base_margin + (margin * item.button_placement)
	icon.texture = item.icon
