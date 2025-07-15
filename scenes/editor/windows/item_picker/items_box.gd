extends VBoxContainer


export var placeable_items: Resource
export var item_button_scene: PackedScene
export var initial_group: String = ""


onready var tile_items_box: GridContainer = get_node("%TileItems")
onready var object_items_box: GridContainer = get_node("%ObjectItems")


func _ready():
	load_items(get_items_by_group(initial_group))


func load_items(items: Dictionary):
	if items.size() <= 0:
		return
	
	for item in items.values():
		var item_button = item_button_scene.instance()
		item_button.placeable_item = item
		
		if item is PlaceableTile:
			tile_items_box.add_child(item_button)
		elif item is PlaceableObject:
			object_items_box.add_child(item_button)
			
		print(item_button.connect("item_selected", get_node("%ItemSuitcase"), "item_selected"))


func get_items_by_group(group: String) -> Dictionary:
	var items: Dictionary = placeable_items.placeable_items
	var filtered_items: Dictionary = {}
	
	for item in items.keys():
		var item_data = items[item]
		
		if group == "":
			filtered_items.get_or_add(item, item_data)
		else:
			if group in item_data.groups:
				filtered_items.get_or_add(item, item_data)
	
	return filtered_items


func get_items_by_search(input: String) -> Dictionary:
	input = input.to_lower()
	
	var items: Dictionary = placeable_items.placeable_items
	var filtered_items: Dictionary = {}
	
	# Get the names and IDs in a dictionary, and score them based on how well
	# they fit the input
	var item_names: Dictionary = {}
	var item_scores: Dictionary = {}
	for item in items.keys():
		var score = fuzzy_score(input, items[item].item_name)
		if score > 0:
			item_names.get_or_add(item, items[item].item_name)
			item_scores.get_or_add(item, score)
	
	# Then iterate on the dictionary while seeing if any names fit
	for item in item_names.keys():
		if not item_names[item].to_lower.find(input) == -1:
			filtered_items.get_or_add(item, items[item])
	
	return filtered_items


func fuzzy_score(input: String, item_name: String):
	var score = 0
	var i = 0
	for character in item_name:
		if i >= input.length():
			break
		
		if character == input[i]:
			score += 1
		
		i += 1
	
	return score if i == input.length() else 0


func _sort_by_score(a, b):
	return int(b["score"] - a["score"])
