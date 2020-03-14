extends Sprite

onready var PLACEABLE_ITEM_BUTTON = load("res://scenes/editor/placeable_item_button.tscn")
export var margin := 156
export var base_margin := 12

func _ready():
	var editor = get_tree().get_current_scene()
	var placeable_items = editor.get_node(editor.placeable_items)
	for item in placeable_items.get_children():
		var placeable_item_button = PLACEABLE_ITEM_BUTTON.instance()
		placeable_item_button.item = item
		placeable_item_button.margin = margin
		placeable_item_button.base_margin = base_margin
		add_child(placeable_item_button)
