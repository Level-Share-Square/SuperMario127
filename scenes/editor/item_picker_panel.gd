extends PanelContainer

const TRANS_SPEED: float = 0.4

onready var container: Control = get_parent()
onready var tween = $Tween
onready var hide_margin: float = container.margin_left
var is_shown: bool = false

onready var search = $"%Search"
onready var search_bar = $"%SearchBar"
onready var items_grid = $"%ItemsGrid"
onready var item_label = $"%ItemLabel"

onready var tiles = $"%Tiles"
onready var objects = $"%Objects"
onready var hotbar = $"%Hotbar"

var bar_shown = false

func toggle():
	is_shown = not is_shown
	if is_shown:
		tween.stop_all()
		tween.interpolate_property(
			container, "margin_left", 
			container.margin_left, 0, TRANS_SPEED, 
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
	else:
		tween.stop_all()
		tween.interpolate_property(
			container, "margin_left", 
			container.margin_left, hide_margin, TRANS_SPEED, 
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	item_label.text = ""
	for tile_group in tiles.get_children():
		tile_group.connect("button_down", self, "_on_group_pressed", [tile_group])
	for object_group in objects.get_children():
		object_group.connect("button_down", self, "_on_group_pressed", [object_group])
				
func _on_group_pressed(group):
	if group.pressed == true:
		items_grid.load_items(items_grid.get_items_by_group(""), true)
	else:
		print(group.name)
		items_grid.load_items(items_grid.get_items_by_group(group.name), true)
		
func reset():
	for tile_group in tiles.get_children():
		tile_group.pressed = false
	for object_group in objects.get_children():
		object_group.pressed = false

func item_selected(item):
	var item_type: String
	var item_id: String
	var item_name: String
	if "object_id" in item:
		item_id = str(item.object_id)
	else:
		item_id = str(item.tileset_id)
	item_name = item.item_name
	item_label.text = "%s %s" % [item_id, item_name]
	hotbar.on_item_selected(item)
	
