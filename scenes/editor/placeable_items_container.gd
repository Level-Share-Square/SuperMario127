extends Sprite

onready var PLACEABLE_ITEM_BUTTON = load("res://scenes/editor/placeable_item_button.tscn")
export var number_of_boxes := 7
export var margin := 156
export var base_margin := 12

func _ready():
	var editor = get_tree().get_current_scene()
	var placeable_items = editor.get_node(editor.placeable_items)
	var children = placeable_items.get_children()
	for index in range(number_of_boxes):
		var item
		if index < children.size():
			item = children[index]

		var placeable_item_button = PLACEABLE_ITEM_BUTTON.instance()
		placeable_item_button.item = item
		placeable_item_button.margin = margin
		placeable_item_button.base_margin = base_margin
		placeable_item_button.button_placement = index
		placeable_item_button.placeable_items_path = "../../../PlaceableItems"
		add_child(placeable_item_button)
