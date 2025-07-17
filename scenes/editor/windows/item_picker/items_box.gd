extends VBoxContainer


export var placeable_items: Resource
export var item_button_scene: PackedScene
export var initial_group: String = ""


onready var tile_items_box: GridContainer = get_node("%TileItems")
onready var object_items_box: GridContainer = get_node("%ObjectItems")

onready var search_bar = get_node("%SearchBar")


func _ready():
	search_bar.connect("text_changed", self, "_on_search")
	load_items(get_items_by_group(initial_group), true)


func load_items(items: Array, priority_sort: bool):
	for i in tile_items_box.get_children():
		i.queue_free()
	for i in object_items_box.get_children():
		i.queue_free()
	if items.size() <= 0:
		return
		
	if priority_sort:
		items.sort_custom(self, "_sort_by_priority")
	
	for item in items:
		var item_button = item_button_scene.instance()
		item_button.placeable_item = item
		
		if item is PlaceableTile:
			tile_items_box.add_child(item_button)
		elif item is PlaceableObject:
			object_items_box.add_child(item_button)
			
		item_button.connect("item_selected", owner, "item_selected")


func get_items_by_group(group: String) -> Array:
	var items: Dictionary = placeable_items.placeable_items
	var filtered_items: Array
	
	for item_data in items.values():
		if group.empty():
			filtered_items.append(item_data)
		else:
			if group in item_data.groups:
				filtered_items.append(item_data)
	
	filtered_items.sort_custom(self, "_sort_by_priority")
	
	return filtered_items


func _on_search(new_text):
	sort_by_fuzzy_search(new_text)


#Bad sorting algorithm -dignity
func sort_by_fuzzy_search(search: String):
	if search == "":
		load_items(get_items_by_group(initial_group), true)
		return
	var score_dictionary: Dictionary
	for key in placeable_items.placeable_items:
		var item = key
		var score: int = 0
		var score_ratio: float = 0.0
		for letter_item in item.substr(4, item.length()):
			for letter_search in search:
				if letter_search.to_lower() == letter_item.to_lower():
					score += 1
		score_ratio = float(score)/float(item.length())
		score_dictionary[item] = score_ratio

	var score_array: Array 
	for i in score_dictionary:
		score_array.append({i: score_dictionary[i]})
			
	while true:
		var fail = false
		for pair in score_array:
			var current_index = score_array.find(pair)
			var current_score = pair[pair.keys()[0]]
			if score_array.find(pair) + 1 == score_array.size():
				break
			var next_score = score_array[score_array.find(pair) + 1][score_array[score_array.find(pair) + 1].keys()[0]]
			if next_score > current_score:
				var temp_pair = pair
				score_array.remove(current_index)
				score_array.insert(current_index + 1, pair)
				fail = true
		if fail == false:
			break
	
	var return_array: Array
	for pair in score_array:
		var key = pair.keys()[0]
		return_array.append(placeable_items.placeable_items[key])
	return_array = return_array.slice(0, 9)
	load_items(return_array, false)
	owner.groups.reset()
	return return_array


func _sort_by_priority(a, b):
	if a["priority"] > b["priority"]:
		return true
	return false
