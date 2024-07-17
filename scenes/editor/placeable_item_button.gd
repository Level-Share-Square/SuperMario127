extends TextureButton

onready var icon = $Icon
onready var pin = $Pin
onready var tween = $Tween
onready var sound = $Sound
onready var click_sound = $ClickSound
onready var grid = $Grid
onready var h_box_container = $HBoxContainer
onready var h_box_container_2 = $HBoxContainer2
var normal_texture : StreamTexture
var margin := 0
var base_margin := 0
var button_placement := 0
var normal_color : Color
var selected_color : Color
var item : PlaceableItem
var placeable_items_path : String = ""
onready var placeable_items_node = get_node(placeable_items_path)
var box_index = 1
var editor

var squares = []

var last_hovered = false
var last_clicking = false

func _ready():
	editor = get_tree().get_current_scene()
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
	Singleton.EditorSavedSettings.layout_ids[box_index] = item.name
	item.backup_palette_index = Singleton.EditorSavedSettings.layout_palettes[box_index]
	Singleton.EditorSavedSettings.layout_palettes[box_index] = item.palette_index
	
func is_hovered():
	var mouse_pos = get_global_mouse_position()
	var position = rect_global_position
	if mouse_pos.x > position.x and mouse_pos.x < position.x + 48 and mouse_pos.y > position.y and mouse_pos.y < position.y + 48:
		return true
	else:
		return false

func _process(_delta):
	var hovered = is_hovered()
	grid.visible = true if !item.is_object else false
	grid.mouse_filter = 2 # ignore
	if hovered and !last_hovered:
		
		sound.play()
		tween.interpolate_property(icon, "offset",
			Vector2(0, 3), Vector2(0, 0), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
	if !hovered and last_hovered:
		tween.interpolate_property(icon, "offset",
			Vector2(0, 0), Vector2(0, 3), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
	if(box_index < editor.pinned_items.size()):
		pin.visible = true
	else:
		pin.visible = false

	var clicking = Input.is_action_pressed("place")
	var editor = get_tree().get_current_scene()

	if hovered and Input.is_action_just_pressed("pin_item"):
		if(box_index < editor.pinned_items.size()):
			editor.unpin_item(box_index)
		else:
			editor.pin_item(item)
	if editor.dragging_item != null and hovered:
		texture_normal = texture_hover
		
	else:
		texture_normal = normal_texture
	
	last_hovered = hovered
	last_clicking = clicking
			
func update_selection():
	var editor = get_tree().get_current_scene()
	if editor.selected_box == self:
		self_modulate = selected_color
	else:
		self_modulate = normal_color
		
	for child in h_box_container.get_children():
		child.queue_free() # releasing children from prison
		
	for child in h_box_container_2.get_children():
		child.queue_free() # releasing children from prison: the sequel
		
	for index in range(item.items_in_sequence):
		var box = ColorRect.new()
		box.rect_min_size = Vector2(8, 8)
		box.rect_size = Vector2(8, 8)
		box.color = Color(0.75, 0.75, 0.75) if item.index_in_sequence != index else Color(0, 0.75, 0.75)
		h_box_container.add_child(box)
	
	for index in range(item.palette_icons.size()):
		var box = ColorRect.new()
		box.rect_min_size = Vector2(8, 8)
		box.rect_size = Vector2(8, 8)
		box.color = Color(0.75, 0.75, 0.75) if item.palette_index != index else Color(0, 0.75, 0.75)
		h_box_container_2.add_child(box)


func button_down():
	var editor = get_tree().get_current_scene()
	
	if item != null:
		if Input.is_action_just_pressed("change_palette"):
			
			Singleton2.new_box.item.update_palette(Singleton2.new_box.item.palette_index + 1)
			item_changed()
		elif editor.selected_box == self and !item.change_to.empty():
			var old_palette_index = item.palette_index
			item = placeable_items_node.find_node(item.change_to)
			item.update_palette(old_palette_index)
			item_changed()
		
		click_sound.play()
		tween.interpolate_property(icon, "position",
			Vector2(0, 0), Vector2(0, -18), 0.075,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
	editor.set_selected_box(self)


func button_up():
	if item != null:
		tween.interpolate_property(icon, "position",
			Vector2(0, -18), Vector2(0, 0), 0.15,
			Tween.TRANS_BOUNCE, Tween.EASE_IN)
		tween.start()
