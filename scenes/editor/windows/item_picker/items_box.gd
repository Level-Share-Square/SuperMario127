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
#	print(filtered_items)
	return filtered_items


func _on_search(new_text: String = search_bar.text):
	sort_by_fuzzy_search(new_text)


# better sorting algorithm -dignity
func sort_by_fuzzy_search(search: String):
	if search == "":
		load_items(get_items_by_group(initial_group), true)
		return
	var score_array: Array
	for key in placeable_items.placeable_items:
		var item_name: String = key.substr(4)
		var score: float = 0
		
		if item_name.findn(search) != -1:
			score += 10
					
		if search.is_subsequence_ofi(item_name):
			score += 5
			
		score += item_name.similarity(search) * 2
		
		if score > 0:
			score_array.append({"data": placeable_items.placeable_items[key], "score": score})
			
	score_array.sort_custom(self, "_sort_by_score")
	
	score_array = score_array.slice(0, 19)
	var return_array: Array
	for pair in score_array:
		return_array.append(pair["data"])
		
	load_items(return_array, false)
	item_picker_panel.reset()
	return return_array


func _sort_by_priority(a, b):
	if a["priority"] > b["priority"]:
		return true
	return false


func _sort_by_score(a, b):
	return a["score"] > b["score"]
