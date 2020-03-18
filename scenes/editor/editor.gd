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

var lock_axis = "none"
var lock_pos = 0
var last_mouse_pos = Vector2(0, 0)

func _ready():
	var data = CurrentLevelData.level_data
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
		var mouse_pos = get_global_mouse_position()
		var mouse_screen_pos = get_viewport().get_mouse_position()
		if Input.is_action_pressed("lock_tile_axis") and (Input.is_action_pressed("place") or Input.is_action_pressed("erase")):
			if Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
				if abs(mouse_pos.x) - abs(last_mouse_pos.x) > abs(mouse_pos.y) - abs(last_mouse_pos.y):
					lock_axis = "x"
					lock_pos = mouse_pos.x
				else:
					lock_axis = "y"
					lock_pos = mouse_pos.y
			if lock_axis == "x":
				mouse_pos.x = lock_pos
			elif lock_axis == "y":
				mouse_pos.y = lock_pos
		else:
			lock_axis = "none"
			lock_pos = 0
		
		var mouse_tile_pos = Vector2(floor(mouse_pos.x / 32), floor(mouse_pos.y / 32))
		var tile_index = tile_util.get_tile_index_from_position(mouse_tile_pos, level_area.settings.size)
		
		if Input.is_action_pressed("place") and selected_box and selected_box.item:
			var item = selected_box.item
			var layer = 1 # magic numbers suck
			
			if !item.is_object:
				shared_node.set_tile(tile_index, layer, item.tileset_id, item.tile_id)
			else:
				var object_pos = (mouse_tile_pos * 32) + item.object_center
				if !shared_node.get_object_at_position(object_pos): # can't get this to work, maybe you could try
					var object = LevelObject.new()
					object.type_id = item.object_id
					object.properties = {}
					object.properties.position = object_pos
					object.properties.scale = Vector2(1, 1)
					object.properties.rotation_degrees = 0
					shared_node.create_object(object, true)
		elif Input.is_action_pressed("erase"):
			var layer = 1
			
			shared_node.set_tile(tile_index, layer, 0, 0)
		last_mouse_pos = mouse_pos
