extends TextureButton

onready var icon = $Icon
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
onready var grid = $Grid
onready var h_box_container = $HBoxContainer
var normal_texture : StreamTexture
var margin := 0
var base_margin := 0
var button_placement := 0
var normal_color : Color
var selected_color : Color
var item : PlaceableItem
var placeable_items_path : String = ""
var box_index = 1

var squares = []

var last_hovered = false
var last_clicking = false

func _ready():
	texture_normal = load(texture_normal.load_path)
	texture_hover = load(texture_hover.load_path)
	texture_pressed = load(texture_pressed.load_path)
	grid.texture = load(grid.texture.load_path) # modern problems require modern solutions
	margin_left = base_margin + (margin * button_placement)
	normal_texture = texture_normal
	item_changed()
	update_selection()

func item_changed():
	icon.texture = null if item == null else item.icon
	EditorSavedSettings.layout_ids[box_index] = item.name
	
func is_hovered():
	var mouse_pos = get_global_mouse_position()
	var position = rect_global_position
	if mouse_pos.x > position.x and mouse_pos.x < position.x + 48 and mouse_pos.y > position.y and mouse_pos.y < position.y + 48:
		return true
	else:
		return false
	
func _process(_delta):
	grid.visible = true if !item.is_object else false
	grid.mouse_filter = 2 # ignore
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
		
	for child in h_box_container.get_children():
		child.queue_free() # releasing children from prison
		
	for index in range(item.items_in_sequence):
		var box = ColorRect.new()
		box.rect_min_size = Vector2(8, 8)
		box.rect_size = Vector2(8, 8)
		box.color = Color(0.75, 0.75, 0.75) if item.index_in_sequence != index else Color(0, 0.75, 0.75)
		h_box_container.add_child(box)
