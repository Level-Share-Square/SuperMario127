extends LevelDataLoader

const COIN_ANIM_FPS = 12
const LAYER_COUNT = 4

var mode = 1

onready var placement_nodes = [
	null,
	null,
	null,
	$Placement/RectangleFill
]

export var placement_mode := "Drag"
export var surface_snap := false
export var placeable_items_path : NodePath
export var placeable_items_button_container_path : NodePath
export var item_preview_path : NodePath
export var shared_path : NodePath
export var object_settings_path : NodePath
export var mouse_object_area_path : NodePath
var selected_box : Node
# Placed objects can use this variable when set in the placement action
var placed_item_property = null

var dragging_item : Node
var display_preview_item = true

onready var placeable_items : Node = get_node(placeable_items_path)
onready var placeable_items_button_container : TextureRect = get_node(placeable_items_button_container_path)
onready var pinned_items : Array 
onready var max_pins = 5
onready var item_preview : Sprite = get_node(item_preview_path)
onready var shared : Node2D = get_node(shared_path)
onready var object_settings : NinePatchRect = get_node(object_settings_path)
onready var mouse_object_area : Area2D = get_node(mouse_object_area_path)

onready var bounds_control = $BoundsControl
onready var camera : Camera2D = $Camera2D

var lock_axis := "none"
var lock_pos := 0
var last_mouse_pos := Vector2(0, 0)
var last_mouse_tile_pos := Vector2(0, 0)


var timer = 2
var object_pos : Vector2


var left_held := false
var right_held := false
var last_left_held := false
var last_right_held := false

var hovered_object : GameObject
var rotating := false

var time_clicked := 0.0

export var editing_layer := 1
export var layers_transparent := false

export var selected_tool := 0
export var zoom_level := 1.0

var tiles_stack := []
var objects_stack := []

var coin_frame : int

onready var normal_boo = preload("res://assets/tiles/boo_block/icon.png")
onready var invis_boo = preload("res://assets/tiles/boo_block/boo_block_invis.png")

signal zoom_changed(zoom)


func quit_to_menu():
	var level_id: String = Singleton.CurrentLevelData.level_id
	var working_folder: String = Singleton.CurrentLevelData.working_folder
	
	var code_path: String = level_list_util.get_level_file_path(level_id, working_folder)
	var level_code: String = level_list_util.load_level_code_file(code_path)
	
	Singleton.CurrentLevelData.level_info = LevelInfo.new(level_id, working_folder, level_code)
	if Singleton.SceneSwitcher.menu_return_args.size() > 0:
		Singleton.SceneSwitcher.menu_return_args = [Singleton.CurrentLevelData.level_info, level_id, working_folder, true]
	
	Singleton.SceneSwitcher.quit_to_menu_with_transition("levels_screen")


# Functions to avoid copy pasted code
func cap_zoom_level(level : float) -> float:
	# Reduce the zoom level if the screen wouldn't fit within the level
	# NOTE: all values are -6 since there are 3 tiles OOB in both directions for both axis
	var level_size : Vector2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds.size
	
	while (393*level > level_size.x*17) or (216*level > level_size.y*17):
		level = level-.25
	
	return level

func set_zoom_level(level : float) -> void:
	# Zoom level limits
	if level < 0.25: level = 0.25
#	if level > 1.75: level = 1.75 #we don't be limiting the zoom size around here
	
	zoom_level = cap_zoom_level(level) # makes sure the zoom isn't too large when
	Singleton.EditorSavedSettings.zoom_level = zoom_level
	emit_signal("zoom_changed", zoom_level)

func add_zoom_level(level : float) -> void:
	set_zoom_level(zoom_level + level)

func switch_layers() -> void:
	editing_layer = wrapi(editing_layer + 1, 0, LAYER_COUNT)
	Singleton.EditorSavedSettings.layer = editing_layer
	
	shared.toggle_layer_transparency(editing_layer, layers_transparent)

func _unhandled_input(event) -> void:
	if Singleton2.disable_hotkeys == false:
		if event.is_action_pressed("switch_placement_mode"):
			placement_mode = "Tile" if placement_mode == "Drag" else "Drag"
		elif event.is_action_pressed("toggle_surface_snap"):
			surface_snap = !surface_snap
		elif event.is_action_pressed("place") and !Input.is_action_pressed("erase"):
			left_held = true
		elif event.is_action_released("place"):
			left_held = false
		elif event.is_action_pressed("erase") and !Input.is_action_pressed("place"):
			right_held = true
		elif event.is_action_released("erase"):
			right_held = false
		elif event.is_action_pressed("undo"):
			Singleton.ActionManager.undo()
		elif event.is_action_pressed("redo"):
			Singleton.ActionManager.redo()
		elif event.is_action_pressed("pencil_tool"):
			selected_tool = 0
		elif event.is_action_pressed("eraser_tool"):
			selected_tool = 1
		elif event.is_action_pressed("zoom_out"):
			add_zoom_level(0.25)
		elif event.is_action_pressed("zoom_in"):
			add_zoom_level(-0.25)
		
		if event.is_action_pressed("switch_layers"):
			switch_layers()
		if event.is_action_pressed("toggle_transparency"):
			layers_transparent = !layers_transparent
			Singleton.EditorSavedSettings.layers_transparent = layers_transparent
			shared.toggle_layer_transparency(editing_layer, layers_transparent)

func _ready() -> void:
	Engine.set_target_fps(0)
	Engine.iterations_per_second = 60
	# reset these to 0 since they get incremented by the loading in process every time
	Singleton.CurrentLevelData.next_shine_id = 0
	Singleton.CurrentLevelData.next_star_coin_id = 0
	Singleton.CheckpointSaved.reset()

	var data = Singleton.CurrentLevelData.level_data
	load_in(data, data.areas[Singleton.CurrentLevelData.area])
	zoom_level = Singleton.EditorSavedSettings.zoom_level
	editing_layer = Singleton.EditorSavedSettings.layer
	layers_transparent = Singleton.EditorSavedSettings.layers_transparent
	
	for pinned_item in Singleton.CurrentLevelData.level_data.pinned_items:
		var item: Node = placeable_items.find_node(pinned_item[0])
		item.palette_index = pinned_item[1]
		pinned_items.append(item)
	
	shared.toggle_layer_transparency(editing_layer, layers_transparent)
	
	# if the mode switch button is invisible then the editor hasn't been readyed for the first time yet
	# (editor _ready() gets called every time a mode switch happens)
	# if the button is invisible and we're in the editor scene, we know it's time to setup the editor for the first time
	if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		# enable the mode switching button since we're using the editor
		Singleton.ModeSwitcher.get_node("ModeSwitcherButton").change_button_state(true)
		Singleton.Music.play() # needed as the music no longer plays by default

		# make sure the mode switcher button is set to have the play button as it's visual
		Singleton.ModeSwitcher.get_node("ModeSwitcherButton").change_visuals(0)

		Singleton.CurrentLevelData.unsaved_editor_changes = false
	
func set_selected_box(new_selected_box: Node) -> void:
	Singleton.EditorSavedSettings.selected_box = new_selected_box.box_index
	Singleton2.new_box = new_selected_box
	item_preview.update_preview(new_selected_box.item)
	selected_box = new_selected_box
	for placeable_item_button in placeable_items_button_container.get_children():
		placeable_item_button.update_selection()
		
# Recursive functions to find an item and a tile respectively within PlaceableItems
func pick_item_recursive_find(id: int, group: Node) -> PlaceableItem:
	if group is PlaceableItem:
		return group as PlaceableItem if group.is_object and group.object_id == id else null
	else:
		for node in group.get_children():
			var result := pick_item_recursive_find(id, node)
			if result != null:
				return result
	return null

func pick_tile_recursive_find(tileset_id: int, tile_id: int, group: Node) -> PlaceableItem:
	if group is PlaceableItem:
		return group as PlaceableItem if\
		!group.is_object and group.tileset_id == tileset_id and group.tile_id == tile_id else null
	else:
		for node in group.get_children():
			var result := pick_tile_recursive_find(tileset_id, tile_id, node)
			if result != null:
				return result
	return null

# Pick a GameObject as a PlaceableItem
func pick_item(obj: GameObject) -> void:
	var level_object = obj.level_object.get_ref()
	var id : int = level_object.type_id
	var placeable_item := pick_item_recursive_find(id, placeable_items)
	if placeable_item == null: return # In case
	
	# Should probably go into a function
	# yeah i agree
	update_button_container(placeable_item)
	

# Pick a tile as a PlaceableItem
func pick_tile(tile) -> void:
	var tileset_id = tile[0]
	var tile_id = tile[1]
	var placeable_item := pick_tile_recursive_find(tileset_id, tile_id, placeable_items)
	if placeable_item == null: return # In case
	placeable_item.palette_index = tile[2]
	# Should probably go into a function
	update_button_container(placeable_item)
	
	item_preview.update_preview(placeable_item)
func find_tile(tile):
	var tileset_id = tile[0]
	var tile_id = tile[1]
	var placeable_item := pick_tile_recursive_find(tileset_id, tile_id, placeable_items)
	return placeable_item
func find_item(obj: GameObject):
	var level_object = obj.level_object.get_ref()
	var id : int = level_object.type_id
	var placeable_item := pick_item_recursive_find(id, placeable_items)
	return placeable_item
	
func dupe_tile(tile) -> void:
	var tileset_id = tile[0]
	var tile_id = tile[1]
	var placeable_item := pick_tile_recursive_find(tileset_id, tile_id, placeable_items)
	if placeable_item == null: return # In case
	# Should probably go into a function
	update_button_container(placeable_item)
	
# Updates the item hotbar after selecting a new item from the menu
func update_button_container(placeable_item):
	var button_container = placeable_items_button_container
	var boxes = button_container.get_children()
	for index in range(button_container.number_of_boxes - 1, pinned_items.size(), -1):
		var box = boxes[index]
		box.item = boxes[index -1].item
		box.item_changed()
	boxes[pinned_items.size()].item = placeable_item
	boxes[pinned_items.size()].item_changed()
	set_selected_box(boxes[pinned_items.size()])
	
# Same as update_button_container but specifically for pinning
func pin_item(placeable_item):
	var max_index
	var button_container = placeable_items_button_container
	var boxes = button_container.get_children()
	
	#update pinned items array
	if pinned_items.size() >= max_pins:
		pinned_items.pop_back()
		max_index = max_pins - 1
	else:
		max_index = button_container.number_of_boxes - 1
	pinned_items.push_front(placeable_item)
	
	for index in range(max_index, 0, -1):
		var box = boxes[index]
		box.item = boxes[index - 1].item
		box.item_changed()
	boxes[0].item = placeable_item
	boxes[0].item_changed()
	set_selected_box(boxes[0])
	
func unpin_item(unpin_index):
	var button_container = placeable_items_button_container
	var boxes = button_container.get_children()
	var temp_box = boxes[unpin_index]
	
	for index in range(unpin_index, pinned_items.size()):
		var box = boxes[index]
		box.item = boxes[index + 1].item
		box.item_changed()
	boxes[pinned_items.size()].item = temp_box.item
	boxes[pinned_items.size()].item_changed()
	pinned_items.remove(unpin_index)


func sync_pinned_items() -> void:
	var encoded_pinned_items: Array
	for pinned_item in pinned_items:
		var pin_array: Array
		pin_array.append(pinned_item.name)
		pin_array.append(pinned_item.palette_index)
		encoded_pinned_items.append(pin_array)
	Singleton.CurrentLevelData.level_data.pinned_items = encoded_pinned_items


func switch_scenes() -> void:
	sync_pinned_items()
	
	if Singleton2.rp == true:
		update_activity()
	elif Singleton2.rp == false:
		if Singleton2.dead == false:
			Discord.queue_free()
			Singleton2.dead = true
		elif Singleton2.dead == true:
			pass
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")
	
	
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("Playtesting a level")

	var assets = activity.get_assets()
	assets.set_large_image("sm127")
	assets.set_large_text("0.9.0")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 1)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		printerr(str(result))

func update_selected_object(mouse_pos : Vector2) -> void:
	if mouse_object_area.position != mouse_pos:
		mouse_object_area.position = mouse_pos
	if selected_box.item.is_object and !rotating and time_clicked <= 0:
		var mouse_object_rect = Rect2(mouse_object_area.position-mouse_object_area.get_child(0).shape.extents, mouse_object_area.get_child(0).shape.extents*2)
		var objects = shared.get_objects_overlapping_position(mouse_pos, mouse_object_rect, mouse_object_area)
		if objects.size() > 0 and placement_mode != "Tile":
			if hovered_object != objects[0]:
				# If something was already hovered, mark it as not
				if is_instance_valid(hovered_object):
					hovered_object.modulate = Color(1, 1, 1, hovered_object.modulate.a)
					hovered_object.hovered = false
				
				hovered_object = objects[0]
				hovered_object.hovered = true
				hovered_object.modulate = Color(0.65, 0.65, 1, hovered_object.modulate.a)
				item_preview.visible = false
		elif is_instance_valid(hovered_object):
			hovered_object.modulate = Color(1, 1, 1, hovered_object.modulate.a)
			hovered_object.hovered = false
			hovered_object = null
			item_preview.visible = true


					

func _process(delta : float) -> void:
	var visible_child_count := 0
	for i in $UI.get_children():
		if i is NinePatchRect:
			if i.visible:
				visible_child_count += 1

#	if ui_visible != $UI.visible:
#		ui_visible = $UI.visible

	if visible_child_count == 0:
		Singleton2.disable_hotkeys = false
	else:
		Singleton2.disable_hotkeys = true

	if Singleton2.time > 0:
		Singleton2.time -= 1
	if Singleton2.time <= 0:
		sync_pinned_items()
		
		var level_info = Singleton.CurrentLevelData.level_info
		var time = round(Time.get_unix_time_from_system())
		
		var level_id: String = Singleton.CurrentLevelData.level_id
		var working_folder: String = Singleton.CurrentLevelData.working_folder
		# whoever coded this previously, u should know this was essentially making it
		# turn the level data into a code four times over
		var level_code: String = Singleton.CurrentLevelData.level_data.get_encoded_level_data()
		var file_path: String = level_list_util.get_level_file_path(level_id, working_folder)
		
		Singleton.CurrentLevelData.level_info = LevelInfo.new(level_id, working_folder, level_code)
		Singleton.CurrentLevelData.level_info.load_in()
		level_list_util.save_level_code_file(level_code, file_path)
		
		level_list_util.autosave_level_to_disk(level_code, "user://autosaves/" + "main_" + str(level_info.level_name) + ".autosave")
		level_list_util.autosave_level_to_disk(level_code, "user://autosaves/" + str(level_info.level_name) + "_" + str(time) + ".autosave")
		Singleton.CurrentLevelData.unsaved_editor_changes = false
		
		Singleton2.reset_time()
	# warning-ignore: integer_division
	coin_frame = (OS.get_ticks_msec() * COIN_ANIM_FPS / 1000) % 4
	
	# For some strange reason, setting it to null right after the object is created
	# causes issues, so wait a frame instead by placing the assignment over here
	placed_item_property = null
	
	zoom_level = cap_zoom_level(zoom_level); # Make sure it didn't accidentally get larger somehow
	
	if Input.is_action_just_pressed("invis_ui") and Singleton2.disable_hotkeys == false:
		$"UI".visible = !$"UI".visible
		$"Grid".visible = !$"Grid".visible
		$"PlaceableItems/MiscGroup/BooBlock".preview = invis_boo
		Singleton.ModeSwitcher.offset.y = 100000 if !$"UI".visible else 0
	
	if get_viewport().get_mouse_position().y > 70: # Mouse is below the toolbar
		var mouse_pos := get_global_mouse_position()
		var mouse_tile_pos := Vector2(floor(mouse_pos.x / selected_box.item.tile_mode_step), floor(mouse_pos.y / selected_box.item.tile_mode_step))
		
		# Lock mouse movement in one axis
#		if mouse_pos != last_mouse_pos:
#			if Input.is_action_pressed("lock_tile_axis") and (Input.is_action_pressed("place") or Input.is_action_pressed("erase")):
#				if Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
#					if abs(mouse_pos.x) - abs(last_mouse_pos.x) > abs(mouse_pos.y) - abs(last_mouse_pos.y):
#						lock_axis = "x"
#						lock_pos = int(mouse_pos.x)
#					else:
#						lock_axis = "y"
#						lock_pos = int(mouse_pos.y)
#				if lock_axis == "x":
#					mouse_pos.x = lock_pos
#				elif lock_axis == "y":
#					mouse_pos.y = lock_pos
#			else:
#				lock_axis = "none"
#				lock_pos = 0
		
		# Handle hovered objects
		if is_instance_valid(hovered_object):
			if Singleton2.disable_hotkeys == false:
				if Input.is_action_just_pressed("rotate"):
					rotating = true
				
				if Input.is_action_just_pressed("flip_object"):
					hovered_object.set_property("scale", Vector2(-hovered_object.scale.x, hovered_object.scale.y), true)
				
				if Input.is_action_just_pressed("flip_object_v"):
					hovered_object.set_property("scale", Vector2(hovered_object.scale.x, -hovered_object.scale.y), true)
				
				if Input.is_action_just_pressed("toggle_enabled"):
					hovered_object.set_property("enabled", !hovered_object.enabled, true)
				
				if Input.is_action_just_pressed("minecraft_pick_block"):
					pick_item(hovered_object)
	#
				if Input.is_mouse_button_pressed(4):
					hovered_object.set_property("scale", Vector2(10, 10), true)
			
			
			if left_held and selected_tool == 0 and Input.is_action_just_pressed("place") and !rotating and selected_box.item.is_object:
				if Input.is_action_pressed("duplicate"):
					var object := LevelObject.new()
					var original_object : LevelObject = hovered_object.level_object.get_ref()
					object.type_id = original_object.type_id
					object.palette = original_object.palette
					for prop in original_object.properties:
						#Prevents a bug that causes certain properties to become
						#Linked between two objects
						if typeof(prop) == TYPE_OBJECT:
							object.properties.append(prop.duplicate(true))
						else:
							object.properties.append(prop)
					shared.create_object(object, true)
					update_selected_object(mouse_pos) # Switch to the new object
				time_clicked += delta
			
			if time_clicked > 0 and left_held:
				time_clicked += delta
				if time_clicked > 0.2:
					var obj_position := mouse_pos
					if !Input.is_action_pressed("8_pixel_lock"):
						obj_position = Vector2(stepify(obj_position.x, 8), stepify(obj_position.y, 8))
					hovered_object.set_property("position", obj_position, true)
			
			if rotating:
				hovered_object.rotation = deg2rad(-90) + hovered_object.position.angle_to_point(mouse_pos)
				if !Input.is_action_pressed("8_pixel_lock"):
					hovered_object.rotation_degrees = stepify(hovered_object.rotation_degrees, 15)
			
			if Input.is_action_just_released("place") and time_clicked > 0 and time_clicked < 0.2:
				if !rotating:
					object_settings.open_object(hovered_object)
			
			if Input.is_action_just_released("place") and rotating:
				rotating = false
				hovered_object.set_property("rotation_degrees", fmod(hovered_object.rotation_degrees, 360), true)
		
		if selected_box and selected_box.item:
			var last_object_pos : Vector2
			
			
			# adios!! (enters portal to "not 600 line script" dimension)
			var placement_node: Control = placement_nodes[selected_tool]
			if is_instance_valid(placement_node):
				placement_node.selected_box = selected_box
				placement_node.editing_layer = editing_layer
				
				placement_node.mouse_pos = mouse_pos
				placement_node.mouse_tile_pos = mouse_tile_pos
				
				placement_node.left_down = left_held
				placement_node.right_down = right_held
				placement_node.selected_update()
			
			
			# Place items
			
			if left_held and selected_tool == 0:
				var item = selected_box.item
				
				if !item.is_object: # Place tile
					# Don't spam place tiles into the same spot
					if ((mouse_tile_pos != last_mouse_tile_pos or Input.is_action_just_pressed("place"))
						and item.on_place(mouse_tile_pos, level_data, level_area) and level_area.settings.bounds.has_point(mouse_tile_pos+Vector2(0.5,0.5))):
						var last_tile = shared.get_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer)
						
						if !(last_tile[0] == item.tileset_id and last_tile[1] == item.tile_id):
							tiles_stack.append([mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, last_tile, [item.tileset_id, item.tile_id, item.palette_index]])
						
						shared.set_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, item.tileset_id, item.tile_id, item.palette_index)
				elif !is_instance_valid(hovered_object) and !rotating: # Place object
					
						
					if placement_mode == "Tile":
						object_pos = (mouse_tile_pos * item.tile_mode_step) + item.object_center
					elif Input.is_action_just_pressed("place"):
						object_pos = mouse_pos
						if !Input.is_action_pressed("8_pixel_lock"):
							object_pos = Vector2(stepify(object_pos.x, 8), stepify(object_pos.y, 8))
						if surface_snap:
							var object_bottom := object_pos + Vector2(0, item.object_size.y)
							var space_state := get_world_2d().direct_space_state
							var result := space_state.intersect_ray(object_bottom, object_bottom + Vector2(0, 16))
							if result:
								object_pos = result.position - Vector2(0, item.object_size.y)
					# I am truly sorry for writing this god forsaken code
					

						
					
					if object_pos and !shared.is_object_at_position(object_pos) and item.on_place(object_pos, level_data, level_area):
						var object := LevelObject.new()
						object.type_id = item.object_id
						object.palette = item.palette_index
						object.properties.append(object_pos)
						object.properties.append(Vector2(1, 1))
						object.properties.append(0)
						object.properties.append(true)
						object.properties.append(true)
						var object_copy = object
						objects_stack.append([shared.create_object(object, true),true,object_copy])
						# Merciful Lord Jesus, please forgive me for 
						# writing this abhorrent line of code. Amen.
						last_object_pos = object_pos
						
					if Input.is_action_pressed("clickdrag"):
						last_object_pos = object_pos
						mouse_pos = get_global_mouse_position()
						var length_difference = mouse_pos - last_object_pos

						if(abs(length_difference.x) >= item_preview.texture.get_width()):
							object_pos.x = last_object_pos.x + item_preview.texture.get_width() * (length_difference.x/abs(length_difference.x))

						elif(abs(length_difference.y) >= item_preview.texture.get_height()):
							object_pos.y = last_object_pos.y + item_preview.texture.get_height() * (length_difference.y/abs(length_difference.y))
						
			elif left_held and selected_tool == 2 and !is_instance_valid(hovered_object) and !rotating and selected_box.item.is_object:
				var item = selected_box.item
				if timer <= 0:
					object_pos = mouse_pos
					timer = 2
				else:
					timer -= 1
				object_pos = Vector2(stepify(object_pos.x, 8), stepify(object_pos.y, 8))
				if surface_snap:
					var object_bottom := object_pos + Vector2(0, item.object_size.y)
					var space_state := get_world_2d().direct_space_state
					var result := space_state.intersect_ray(object_bottom, object_bottom + Vector2(0, 16))
					if result:
						object_pos = result.position - Vector2(0, item.object_size.y)
				# I am truly sorry for writing this god forsaken code
				

					
				
				if object_pos and !shared.is_object_at_position(object_pos) and item.on_place(object_pos, level_data, level_area):
					var object := LevelObject.new()
					object.type_id = item.object_id
					object.palette = item.palette_index
					object.properties.append(object_pos)
					object.properties.append(Vector2(1, 1))
					object.properties.append(0)
					object.properties.append(true)
					object.properties.append(true)
					var object_copy = object
					objects_stack.append([shared.create_object(object, true),true,object_copy])
					# Merciful Lord Jesus, please forgive me for 
					# writing this abhorrent line of code. Amen.
					last_object_pos = object_pos
					
					mouse_pos = get_global_mouse_position()
					var length_difference = mouse_pos - last_object_pos

					if(abs(length_difference.x) >= item_preview.texture.get_width()):
						object_pos.x = last_object_pos.x + item_preview.texture.get_width() * (length_difference.x/abs(length_difference.x))

					elif(abs(length_difference.y) >= item_preview.texture.get_height()):
						object_pos.y = last_object_pos.y + item_preview.texture.get_height() * (length_difference.y/abs(length_difference.y))

						
						
			# Delete items
			if (right_held and selected_tool < 2) or (left_held and selected_tool == 1):
				var item = selected_box.item
				if item.is_object: # Delete object
					if placement_mode == "Tile":
						var object_pos : Vector2 = (mouse_tile_pos * item.tile_mode_step) + item.object_center
						if item.on_erase(object_pos, level_data, level_area):
							shared.destroy_object_at_position(object_pos, true)
					elif (Input.is_action_pressed("erase") or Input.is_action_just_pressed("place") and selected_tool == 1) and is_instance_valid(hovered_object) and !rotating:
						var item_of_erased_object := pick_item_recursive_find(hovered_object.level_object.get_ref().type_id, placeable_items)
						if item_of_erased_object.on_erase(mouse_pos, level_data, level_area):
							shared.destroy_object(hovered_object, true)
							hovered_object = null
							item_preview.visible = true
				else: # Delete tile
					if item.on_erase(mouse_tile_pos, level_data, level_area):
						if level_area.settings.bounds.has_point(mouse_tile_pos+Vector2(0.5,0.5)):
							var last_tile = shared.get_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer)
							
							if !(last_tile[0] == 0 and last_tile[1] == 0):
								tiles_stack.append([mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, last_tile, [0, 0, 0]])
							
							shared.set_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, 0, 0)
			
			# Middle click tiles
			var item = selected_box.item
			if Input.is_action_just_pressed("minecraft_pick_block"):
				var item_array : Array
				var tile = shared.get_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer)
				var selected_tile = find_tile(tile)
				for placeable_item_button in placeable_items_button_container.get_children():
					item_array.append(placeable_item_button.item)
				if item_array.has(selected_tile):
					selected_tile.update_palette(tile[2])
					for placeable_item_button in placeable_items_button_container.get_children():
						placeable_item_button.item_changed()
				else:
					pick_tile(tile)
					if item_array.count(find_tile(tile)) > 1:
						find_tile(tile).update_palette(tile[2])
						for placeable_item_button in placeable_items_button_container.get_children():
							placeable_item_button.item_changed()
						
			
			if selected_box.item.is_object and !rotating and time_clicked <= 0:
				update_selected_object(mouse_pos)
		
		
		# Finalise tile placement action (for potential future undo)
		if !left_held:
			time_clicked = 0
			if last_left_held or !right_held and last_right_held:
				# This code is bad, should probably be fixed soon
				var item = selected_box.item
				if !item.is_object:
					var action = Action.new()
					action.type = "place_tile"
					for element in tiles_stack:
						action.data.append(element)
					tiles_stack.clear()
					Singleton.ActionManager.add_action(action)
#				else:
#					var action2 = Action.new()
#					action2.type = "place_object"
#					for element in objects_stack:
#						action2.data.append(element)
#					objects_stack.clear()
#					Singleton.ActionManager.add_action(action2)

				# if an action is being added, that means we should count the count the level data as modified and in need of a save
				Singleton.CurrentLevelData.unsaved_editor_changes = true
		
#		if last_mouse_pos != mouse_pos:
		last_mouse_pos = mouse_pos
		last_mouse_tile_pos = mouse_tile_pos
		last_left_held = left_held
		last_right_held = right_held

func get_shared_node() -> Node:
	return $Shared
