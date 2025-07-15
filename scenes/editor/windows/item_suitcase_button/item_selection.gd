extends ButtonSound


var placeable_item: Resource = preload("res://scenes/editor/items/placeable_items/blue_coin.tres")

signal new_item_selected(placeable_item)

func _ready():
	set_item(placeable_item)
	connect("button_down", self, "button_pressed")


func set_item(value: PlaceableItem):
	placeable_item = value
	
	hint_tooltip = placeable_item.item_name
	icon = placeable_item.icons[0]
	
	
func button_pressed():
	connect("new_item_selected", get_tree().get_current_scene(), "new_item_selected")
	emit_signal("new_item_selected", placeable_item)
