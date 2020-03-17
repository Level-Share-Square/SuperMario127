extends LevelDataLoader

var mode = 1

export var placeable_items : NodePath
export var placeable_items_button_container : NodePath
export var item_preview : NodePath
export var shared : NodePath
var selected_box : Node

onready var placeable_items_node = get_node(placeable_items)
onready var placeable_items_button_container_node = get_node(placeable_items_button_container)
onready var item_preview_node = get_node(item_preview)
onready var shared_node = get_node(shared)

func _ready():
	var data = LevelData.new()
	data.load_in(load("res://assets/level_data/test_level.tres").contents)
	load_in(data, data.areas[0])
	
func set_selected_box(selected_box: Node):
	item_preview_node.update_preview(selected_box.item)
	self.selected_box = selected_box
	for placeable_item_button in placeable_items_button_container_node.get_children():
		placeable_item_button.update_selection()

func switch_scenes():
	get_tree().change_scene("res://scenes/player/player.tscn")

func _process(delta):
	if get_viewport().get_mouse_position().y > 70:
		if Input.is_action_pressed("place") and selected_box and selected_box.item:
			var item = selected_box.item
			
			var mouse_pos = get_global_mouse_position()
			var mouse_screen_pos = get_viewport().get_mouse_position()
			var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
			var tile_index = tile_util.get_tile_index_from_position(mouse_tile_pos, level_area.settings.size)
			var layer = 1 # magic numbers suck
			
			shared_node.set_tile(tile_index, layer, item.tileset_id, item.tile_id)
		elif Input.is_action_pressed("erase"):
			var mouse_pos = get_global_mouse_position()
			var mouse_screen_pos = get_viewport().get_mouse_position()
			var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
			var tile_index = tile_util.get_tile_index_from_position(mouse_tile_pos, level_area.settings.size)
			var layer = 1
			
			shared_node.set_tile(tile_index, layer, 0, 0)
