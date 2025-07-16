extends EditorWindow


signal item_selected(item)


func item_selected(item: PlaceableItem):
	emit_signal("item_selected", item)
