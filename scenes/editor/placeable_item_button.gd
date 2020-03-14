extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
var margin := 0
var base_margin := 0
var button_placement := 0
var normal_color : Color
var selected_color : Color
var item : PlaceableItem
var placeable_items_path : String = ""

var last_hovered = false

func _ready():
	margin_left = base_margin + (margin * button_placement)
	item_changed()
	update_selection()

func item_changed():
	icon.texture = null if item == null else item.icon
	
func _process(delta):
	if is_hovered() and !last_hovered:
		sound.play()
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
		var editor = get_tree().get_current_scene()
		if event.is_pressed() and item != null:
			if editor.selected_item == item:
#				item = get_node(placeable_items_path + "/" + item.change_to)
#				item_changed()
				pass
			
			editor.set_selected_item(item)
			
			click_sound.play()
			tween.interpolate_property(icon, "position",
				Vector2(0, 0), Vector2(0, -18), 0.075,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
			tween.start()
		else:
			tween.interpolate_property(icon, "position",
				Vector2(0, -18), Vector2(0, 0), 0.15,
				Tween.TRANS_BOUNCE, Tween.EASE_IN)
			tween.start()
			
func update_selection():
	var editor = get_tree().get_current_scene()
	if item != null and editor.selected_item == item:
		self_modulate = selected_color
	else:
		self_modulate = normal_color
