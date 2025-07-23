extends GridContainer

export var placeable_items: Resource
export var item_button_scene: PackedScene
export var initial_group: String = "Terrain"
export(Dictionary) var categories

onready var search_bar = get_node("%SearchBar")
onready var item_picker_panel = $"%ItemPickerPanel"
onready var item_label = $"%ItemLabel"


func _ready():
	load_items(get_items_by_group(initial_group), true)


func load_items(items: Array, priority_sort: bool):
	if priority_sort:
		items.sort_custom(self, "_sort_by_priority")
	
	for children in get_children():
		children.queue_free()
		
	for item in items:
		var item_button = item_button_scene.instance()
		item_button.placeable_item = item
		add_child(item_button)
		
		var item_id: String
		var item_name: String
		if "object_id" in item:
			item_id = str(item.object_id)
		else:
			item_id = str(item.tileset_id)
		item_name = item.item_name
		
		var name_display: String = "%s %s" % [item_id, item_name]
		item_button.connect("mouse_entered", item_label, "set_text", [name_display])
		item_button.connect("mouse_exited", item_label, "set_text", [""])
		item_button.connect("item_selected", item_picker_panel, "item_selected")


func get_items_by_group(group: String) -> Array:
	var filtered_items: Array
	
	for item in categories[group.capitalize()].placeable_items:
		filtered_items.append(categories[group.capitalize()].placeable_items[item])
	
	filtered_items.sort_custom(self, "_sort_by_priority")
	return filtered_items


func _on_search(new_text: String = search_bar.text):
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
		var word_array_items = find_words(item.substr(4, item.length()))
		var word_array_search = find_words(search)
		
		for letter_item in item.substr(4, item.length()):
			for letter_search in search:
				if letter_search.to_lower() == letter_item.to_lower():
					score += 1
					
		score_ratio = float(score)/float(item.length())
		for i in word_array_items:
			for j in word_array_search:
				if i == j:
					score_ratio += 1
		score_dictionary[item] = score_ratio

	var score_array: Array 
	for i in score_dictionary:
		score_array.append({i: score_dictionary[i]})
			
	score_array.sort_custom(self, "_sort_by_ascending")
	
	score_array = score_array.slice(0, 19)
	var return_array: Array
	for pair in score_array:
		var key = pair.keys()[0]
		return_array.append(placeable_items.placeable_items[key])
	load_items(return_array, false)
	item_picker_panel.reset()
	return return_array


func find_words(item):
	var word: String
	var word_array: Array
	var letter_counter = 0
	for letters in item:
		if " " in letters:
			letter_counter += 1
			word_array.append(word)
			word = ""
		elif letters != "_":
			letter_counter += 1
			word += letters
		else:
			letter_counter += 1
			word_array.append(word)
			word = ""
		if letter_counter == item.length():
			word_array.append(word)
	return word_array


func _sort_by_priority(a, b):
	if a["priority"] > b["priority"]:
		return true
	return false


func _sort_by_ascending(a, b):
	if a[a.keys()[0]] > b[b.keys()[0]]:
		return true
	return false
