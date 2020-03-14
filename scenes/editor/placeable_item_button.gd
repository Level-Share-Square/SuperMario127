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
var box_index = 1

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
		if event.is_pressed():
			if item != null:
				if editor.selected_box == box_index:
					item = get_node(placeable_items_path + "/" + item.change_to)
					item_changed()
				
				click_sound.play()
				tween.interpolate_property(icon, "position",
					Vector2(0, 0), Vector2(0, -18), 0.075,
					Tween.TRANS_CIRC, Tween.EASE_OUT)
				tween.start()
			editor.set_selected_box(box_index)
		elif item != null:
			tween.interpolate_property(icon, "position",
				Vector2(0, -18), Vector2(0, 0), 0.15,
				Tween.TRANS_BOUNCE, Tween.EASE_IN)
			tween.start()
			
func update_selection():
	var editor = get_tree().get_current_scene()
	if editor.selected_box == box_index:
		self_modulate = selected_color
	else:
		self_modulate = normal_color
