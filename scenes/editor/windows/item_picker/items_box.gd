extends VBoxContainer


export var placeable_items: Resource
export var item_button_scene: PackedScene

onready var tile_items_box: GridContainer = get_node("%TileItems")
onready var object_items_box: GridContainer = get_node("%ObjectItems")


func _ready():
	var items: Dictionary = placeable_items.placeable_items
	
	load_tile_items(items)
	load_object_items(items)


func load_tile_items(items: Dictionary):
	var tile_items: Dictionary
	
	for item in items:
		var item_data = items[item]
		
		if "tile_id" in item_data:
			tile_items.get_or_add(item, items[item])
	
	if tile_items.size() <= 0:
		return
	
	for item in tile_items.values():
		var item_button = item_button_scene.instance()
		item_button.placeable_item = item
		tile_items_box.add_child(item_button)


func load_object_items(items: Dictionary):
	var object_items: Dictionary
	
	for item in items:
		var item_data = items[item]
		
		if "object_id" in item_data:
			object_items.get_or_add(item, items[item])
	
	if object_items.size() <= 0:
		return
	
	for item in object_items.values():
		var item_button = item_button_scene.instance()
		item_button.placeable_item = item
		object_items_box.add_child(item_button)
