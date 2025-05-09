class_name PlaceableItemList
extends Resource


export(Dictionary) var placeable_items


func get_items_in_group(group: String):
	var items: Array = []
	
	for item in placeable_items:
		if item is PlaceableItem:
			if item.groups.has(group):
				items.append(item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
