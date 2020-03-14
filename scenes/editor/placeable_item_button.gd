extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
var margin := 0
var base_margin := 0
var button_placement := 0
var item : PlaceableItem
var placeable_items_path : String = ""

var last_hovered = false

func _ready():
	margin_left = base_margin + (margin * button_placement)
	item_changed()

func item_changed():
	icon.texture = null if item == null else item.icon
	
func _process(delta):
	if is_hovered() and !last_hovered:
		tween.interpolate_property(icon, "offset",
			Vector2(0, 3), Vector2(0, 0), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
	if !is_hovered() and last_hovered:
		tween.interpolate_property(icon, "offset",
			Vector2(0, 0), Vector2(0, 3), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
	last_hovered = is_hovered()
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			item = get_node(placeable_items_path + "/" + item.change_to)
			item_changed()
			
			tween.interpolate_property(icon, "position",
				Vector2(0, 0), Vector2(0, -18), 0.075,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
			tween.start()
		else:
			tween.interpolate_property(icon, "position",
				Vector2(0, -18), Vector2(0, 0), 0.15,
				Tween.TRANS_BOUNCE, Tween.EASE_IN)
			tween.start()
