extends EditorWindow

onready var items_box = $"%ItemsBox"
onready var groups = $"%Groups"

signal item_selected(item)


func item_selected(item: PlaceableItem):
	emit_signal("item_selected", item)
