extends LevelDataLoader

export var placeable_items : NodePath
export var placeable_items_button_container : NodePath
var selected_item : PlaceableItem

onready var placeable_items_node = get_node(placeable_items)
onready var placeable_items_button_container_node = get_node(placeable_items_button_container)

func _ready():
	var data = LevelData.new()
	data.load_in(load("res://assets/level_data/test_level.tres").contents)
	load_in(data, data.areas[0])
	
func set_selected_item(item : PlaceableItem):
	selected_item = item
	for placeable_item_button in placeable_items_button_container_node.get_children():
		placeable_item_button.update_selection()

func switch_scenes():
	get_tree().change_scene("res://scenes/player/player.tscn")
