extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
var normal_texture : StreamTexture
var margin := 0
var base_margin := 0
var button_placement := 0
var normal_color : Color
var selected_color : Color
var item : PlaceableItem
var placeable_items_path : String = ""
var box_index = 1

var last_hovered = false
var last_clicking = false

func _ready():
	margin_left = base_margin + (margin * button_placement)
	normal_texture = texture_normal
	item_changed()

func item_changed():
	icon.texture = null if item == null else item.icon
	
func is_hovered():
	var mouse_pos = get_global_mouse_position()
	var position = rect_global_position
	if mouse_pos.x > position.x and mouse_pos.x < position.x + 48 and mouse_pos.y > position.y and mouse_pos.y < position.y + 48:
		return true
	else:
		return false
	
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
	
	var clicking = Input.is_action_pressed("place")
	var editor = get_tree().get_current_scene()
	
	if editor.dragging_item != null and is_hovered():
		texture_normal = texture_hover
	else:
		texture_normal = normal_texture
		
	if !clicking and last_clicking and editor.dragging_item != null and is_hovered():
		item = editor.dragging_item
		item_changed()
	
	last_hovered = is_hovered()
	last_clicking = clicking
	
func _gui_input(event):
	if event is InputEventMouseButton:
		var editor = get_tree().get_current_scene()
		if event.is_pressed():
			if item != null:
				if editor.selected_box == self:
					item = get_node(placeable_items_path + "/" + item.change_to)
					item_changed()
				
				click_sound.play()
				tween.interpolate_property(icon, "position",
					Vector2(0, 0), Vector2(0, -18), 0.075,
					Tween.TRANS_CIRC, Tween.EASE_OUT)
				tween.start()
			editor.set_selected_box(self)
		elif item != null:
			tween.interpolate_property(icon, "position",
				Vector2(0, -18), Vector2(0, 0), 0.15,
				Tween.TRANS_BOUNCE, Tween.EASE_IN)
			tween.start()
			
func update_selection():
	var editor = get_tree().get_current_scene()
	if editor.selected_box == self:
		self_modulate = selected_color
	else:
		self_modulate = normal_color
