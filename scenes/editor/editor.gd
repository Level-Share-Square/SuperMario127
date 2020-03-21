extends LevelDataLoader

var mode = 1

export var placement_mode := "Drag"
export var surface_snap := false
export var placeable_items : NodePath
export var placeable_items_button_container : NodePath
export var item_preview : NodePath
export var shared : NodePath
var selected_box : Node
var selected_object : Node

onready var placeable_items_node = get_node(placeable_items)
onready var placeable_items_button_container_node = get_node(placeable_items_button_container)
onready var item_preview_node = get_node(item_preview)
onready var shared_node = get_node(shared)

var lock_axis = "none"
var lock_pos = 0
var last_mouse_pos = Vector2(0, 0)

var left_held = false
var right_held = false

export var layer = 1

func switch_layers():
	if layer == 0:
		layer = 1
	elif layer == 1:
		layer = 2
	else:
		layer = 0

func _unhandled_input(event):
	if event.is_action_pressed("switch_placement_mode"):
		placement_mode = "Tile" if placement_mode == "Drag" else "Drag"
	elif event.is_action_pressed("toggle_surface_snap"):
		surface_snap = !surface_snap
	elif event.is_action_pressed("place"):
		left_held = true
	elif event.is_action_released("place"):
		left_held = false
	elif event.is_action_pressed("erase"):
		right_held = true
	elif event.is_action_released("erase"):
		right_held = false

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
		
		if left_held and selected_box and selected_box.item:
			var item = selected_box.item
			
			if !item.is_object:
				if mouse_tile_pos.x > -1 and mouse_tile_pos.y > -1 and mouse_tile_pos.x < level_area.settings.size.x and mouse_tile_pos.y < level_area.settings.size.y:
					shared_node.set_tile(tile_index, layer, item.tileset_id, item.tile_id)
			else:
				var object_pos
				if placement_mode == "Tile":
					object_pos = (mouse_tile_pos * 32) + item.object_center
				elif Input.is_action_just_pressed("place"):
					object_pos = mouse_pos
					if Input.is_action_pressed("8_pixel_lock"):
						object_pos = Vector2(stepify(object_pos.x, 8), stepify(object_pos.y, 8))
					if surface_snap:
						var object_bottom = object_pos + Vector2(0, item.object_size.y)
						var space_state = get_world_2d().direct_space_state
						var result = space_state.intersect_ray(object_bottom, object_bottom + Vector2(0, 16))
						if result:
							object_pos = result.position - Vector2(0, item.object_size.y)
				if object_pos and !shared_node.is_object_at_position(object_pos):
					var object = LevelObject.new()
					object.type_id = item.object_id
					object.properties = {}
					object.properties.position = object_pos
					object.properties.scale = Vector2(1, 1)
					object.properties.rotation_degrees = 0
					shared_node.create_object(object, true)
		elif right_held:
			if selected_box:
				var item = selected_box.item
				if item.is_object:
					if placement_mode == "Tile":
						var object_pos = (mouse_tile_pos * 32) + item.object_center
						shared_node.destroy_object_at_position(object_pos, true)
					elif Input.is_action_just_pressed("erase"):
						shared_node.destroy_objects_overlapping_position(mouse_pos, true)
				else:
					if mouse_tile_pos.x > -1 and mouse_tile_pos.y > -1 and mouse_tile_pos.x < level_area.settings.size.x and mouse_tile_pos.y < level_area.settings.size.y:
						shared_node.set_tile(tile_index, layer, 0, 0)
		last_mouse_pos = mouse_pos
