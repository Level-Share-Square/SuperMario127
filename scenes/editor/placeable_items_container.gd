extends Sprite

onready var PLACEABLE_ITEM_BUTTON = load("res://scenes/editor/placeable_item_button.tscn")
export var number_of_boxes := 7
export var margin := 156
export var base_margin := 12
export var normal_color : Color
export var selected_color : Color
export var editor : NodePath

func _ready():
	var editor = get_tree().get_current_scene()
	var placeable_items = editor.get_node(editor.placeable_items)
	var starting_toolbar = EditorSavedSettings.layout_ids
	for index in range(number_of_boxes):
		var item
		if index < starting_toolbar.size():
			item = placeable_items.get_node(starting_toolbar[index])

		var placeable_item_button = PLACEABLE_ITEM_BUTTON.instance()
		placeable_item_button.item = item
		placeable_item_button.margin = margin
		placeable_item_button.base_margin = base_margin
		placeable_item_button.button_placement = index
		placeable_item_button.placeable_items_path = "../../../PlaceableItems"
		placeable_item_button.normal_color = normal_color
		placeable_item_button.selected_color = selected_color
		placeable_item_button.box_index = index
		if index == EditorSavedSettings.selected_box:
			editor.selected_box = placeable_item_button
		add_child(placeable_item_button)
		
