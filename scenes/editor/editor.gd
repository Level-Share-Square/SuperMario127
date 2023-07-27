extends LevelDataLoader

const COIN_ANIM_FPS = 12
const LAYER_COUNT = 4

var mode = 1

var soft_autosave_timer = 1800

export var placement_mode := "Drag"
export var surface_snap := false
export var placeable_items_path : NodePath
export var placeable_items_button_container_path : NodePath
export var item_preview_path : NodePath
export var shared_path : NodePath
export var object_settings_path : NodePath
var selected_box : Node
# Placed objects can use this variable when set in the placement action
var placed_item_property = null

var dragging_item : Node
var display_preview_item = true

onready var placeable_items : Node = get_node(placeable_items_path)
onready var placeable_items_button_container : TextureRect = get_node(placeable_items_button_container_path)
onready var item_preview : Sprite = get_node(item_preview_path)
onready var shared : Node2D = get_node(shared_path)
onready var object_settings : NinePatchRect = get_node(object_settings_path)

var lock_axis := "none"
var lock_pos := 0
var last_mouse_pos := Vector2(0, 0)
var last_mouse_tile_pos := Vector2(0, 0)

var autosave_timer = 45000

var object_pos : Vector2

var undo_array = []


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

var coin_frame : int

onready var normal_boo = preload("res://assets/tiles/boo_block/icon.png")
onready var invis_boo = preload("res://assets/tiles/boo_block/boo_block_invis.png")

# Functions to avoid copy pasted code
func cap_zoom_level() -> void:
	# Reduce the zoom level if the screen wouldn't fit within the level
	# NOTE: all values are -6 since there are 3 tiles OOB in both directions for both axis
	var level_size : Vector2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds.size
	if (level_size.x < 36 or level_size.y < 16) and zoom_level > 1.5:
		set_zoom_level(1.5)
	# Level size Y is capped at 14. The Y check would be at 13 otherwise
	if level_size.x < 30 and zoom_level > 1.25:
		set_zoom_level(1.25)
	# 1.25 zoom is *just enough* to see the smallest level
	#if (level_size.x < 24 or level_size.y < 9) and zoom_level > 1.0:
	#	set_zoom_level(1.0)

func set_zoom_level(level : float) -> void:
	# Zoom level limits
	if level < 0.25: level = 0.25
	if level > 1.75: level = 1.75
	
	zoom_level = level
	cap_zoom_level(); # Make sure it's not too large
	Singleton.EditorSavedSettings.zoom_level = zoom_level

func add_zoom_level(level : float) -> void:
	set_zoom_level(zoom_level + level)

func get_shared_node() -> Node:
	return shared

func switch_layers() -> void:
	editing_layer = wrapi(editing_layer + 1, 0, LAYER_COUNT)
	Singleton.EditorSavedSettings.layer = editing_layer
	
	shared.toggle_layer_transparency(editing_layer, layers_transparent)

func _unhandled_input(event) -> void:
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
	elif event.is_action_pressed("selection_tool"):
		selected_tool = 2
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
	# reset these to 0 since they get incremented by the loading in process every time
	Singleton.CurrentLevelData.next_shine_id = 0
	Singleton.CurrentLevelData.next_star_coin_id = 0
	Singleton.CheckpointSaved.reset()

	var data = Singleton.CurrentLevelData.level_data
	load_in(data, data.areas[Singleton.CurrentLevelData.area])
	zoom_level = Singleton.EditorSavedSettings.zoom_level
	editing_layer = Singleton.EditorSavedSettings.layer
	layers_transparent = Singleton.EditorSavedSettings.layers_transparent
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
	var button_container = placeable_items_button_container
	var boxes = button_container.get_children()
	var index_size = (button_container.number_of_boxes-1)
	for index in range(button_container.number_of_boxes):
		if index != index_size:
			var box = boxes[index_size - index]
			box.item = boxes[(index_size - index) - 1].item
			box.item_changed()
	boxes[0].item = placeable_item
	boxes[0].item_changed()
	set_selected_box(boxes[0])

# Pick a tile as a PlaceableItem
func pick_tile(tile) -> void:
	var tileset_id = tile[0]
	var tile_id = tile[1]
	var placeable_item := pick_tile_recursive_find(tileset_id, tile_id, placeable_items)
	if placeable_item == null: return # In case
	
	# Should probably go into a function
	var button_container = placeable_items_button_container
	var boxes = button_container.get_children()
	var index_size = (button_container.number_of_boxes-1)
	for index in range(button_container.number_of_boxes):
		if index != index_size:
			var box = boxes[index_size - index]
			box.item = boxes[(index_size - index) - 1].item
			box.item_changed()
	boxes[0].item = placeable_item
	boxes[0].item_changed()
	set_selected_box(boxes[0])

func switch_scenes() -> void:
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
	assets.set_large_text("0.7.2")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 1)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))

func update_selected_object(mouse_pos : Vector2) -> void:
	if selected_box.item.is_object and !rotating and time_clicked <= 0:
		var objects = shared.get_objects_overlapping_position(mouse_pos)
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

func is_platform():
	if "Platform" in hovered_object.to_string():
		return true
	elif "TouchLift" in hovered_object.to_string():
		return true
	elif "Seesaw" in hovered_object.to_string():
		return true
	else:
		return false

func _input(event):
	if is_instance_valid(hovered_object):
		if event is InputEventMouseButton and event.is_pressed():
			if hovered_object != null || hovered_object.to_string() != "[Deleted Object]":
				if !is_platform():
					if get_viewport().get_mouse_position().y > 70: # Mouse is below the toolbar
							if event.button_index == 5: # Mouse wheel down
								hovered_object.set_property("scale", Vector2(hovered_object.scale.x - 0.5, hovered_object.scale.x - 0.5), true)
							elif event.button_index == 4: # Mouse wheel up
								hovered_object.set_property("scale", Vector2(hovered_object.scale.x + 0.5, hovered_object.scale.x + 0.5), true)
					

func _process(delta : float) -> void:

	if autosave_timer > 0:
		autosave_timer -= 1
	if autosave_timer <= 0:
		if Singleton.SavedLevels.selected_level != -1:
			Singleton.SavedLevels.levels[Singleton.SavedLevels.selected_level] = LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data())
			var _error_code = Singleton.SavedLevels.save_level_by_index(Singleton.SavedLevels.selected_level)
		Singleton.CurrentLevelData.unsaved_editor_changes = false
		var level = Singleton.SavedLevels.levels
		var level_info = level[Singleton.SavedLevels.selected_level]
		var file = File.new()
		var time = Time.get_datetime_dict_from_system()
		var hours = time["hour"]
		var minutes = time["minute"]
		var seconds = time["second"]
		
		file.open("user://autosave/" + str(level_info.level_name) + "_" + "hour" + str(hours) + "_" + "minute" + str(minutes) + "_" + "second" + str(seconds) + ".autosave", File.WRITE_READ)
		file.store_var(level_info.level_code)
		file.close()
		
		autosave_timer = 45000
	# warning-ignore: integer_division
	coin_frame = (OS.get_ticks_msec() * COIN_ANIM_FPS / 1000) % 4
	
	# For some strange reason, setting it to null right after the object is created
	# causes issues, so wait a frame instead by placing the assignment over here
	placed_item_property = null
	
	cap_zoom_level(); # Make sure it didn't accidentally get larger somehow
	
	if Input.is_action_just_pressed("invis_ui"):
		$"UI".visible = !$"UI".visible
		$"Grid".visible = !$"Grid".visible
		$"PlaceableItems/MiscGroup/BooBlock".preview = invis_boo
		
	
	if soft_autosave_timer >= 0:
		print(soft_autosave_timer)
		soft_autosave_timer -= 1
	else:
		if Singleton.SavedLevels.selected_level != -1:
			Singleton.SavedLevels.levels[Singleton.SavedLevels.selected_level] = LevelInfo.new(Singleton.CurrentLevelData.level_data.get_encoded_level_data())
			var _error_code = Singleton.SavedLevels.save_level_by_index(Singleton.SavedLevels.selected_level)

			Singleton.CurrentLevelData.unsaved_editor_changes = false
			soft_autosave_timer = 30 / delta
	
	if get_viewport().get_mouse_position().y > 70: # Mouse is below the toolbar
		var mouse_pos := get_global_mouse_position()
		var mouse_tile_pos := Vector2(floor(mouse_pos.x / selected_box.item.tile_mode_step), floor(mouse_pos.y / selected_box.item.tile_mode_step))
		
		# Lock mouse movement in one axis
		if mouse_pos != last_mouse_pos:
			if Input.is_action_pressed("lock_tile_axis") and (Input.is_action_pressed("place") or Input.is_action_pressed("erase")):
				if Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
					if abs(mouse_pos.x) - abs(last_mouse_pos.x) > abs(mouse_pos.y) - abs(last_mouse_pos.y):
						lock_axis = "x"
						lock_pos = int(mouse_pos.x)
					else:
						lock_axis = "y"
						lock_pos = int(mouse_pos.y)
				if lock_axis == "x":
					mouse_pos.x = lock_pos
				elif lock_axis == "y":
					mouse_pos.y = lock_pos
			else:
				lock_axis = "none"
				lock_pos = 0
		
		# Handle hovered objects
		if is_instance_valid(hovered_object):
			if Input.is_action_just_pressed("rotate"):
				rotating = true
			
			if Input.is_action_just_pressed("flip_object"):
				hovered_object.set_property("scale", Vector2(-hovered_object.scale.x, hovered_object.scale.y), true)
			
			if Input.is_action_just_pressed("flip_object_v"):
				hovered_object.set_property("scale", Vector2(hovered_object.scale.x, -hovered_object.scale.y), true)
			
			if Input.is_action_just_pressed("toggle_enabled"):
				hovered_object.set_property("enabled", !hovered_object.enabled, true)
			
#			if Input.is_action_just_pressed("minecraft_pick_block"):
#				pick_item(hovered_object)
#
			if Input.is_mouse_button_pressed(4):
				hovered_object.set_property("scale", Vector2(10, 10), true)
				
				
				
			
			if left_held and selected_tool == 0 and Input.is_action_just_pressed("place") and !rotating:
				if Input.is_action_pressed("duplicate"):
					var object := LevelObject.new()
					var original_object : LevelObject = hovered_object.level_object.get_ref()
					object.type_id = original_object.type_id
					object.palette = original_object.palette
					for prop in original_object.properties:
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
				hovered_object.rotation = -90 + hovered_object.position.angle_to_point(mouse_pos)
				if !Input.is_action_pressed("8_pixel_lock"):
					hovered_object.rotation_degrees = stepify(hovered_object.rotation_degrees, 15)
			
			if Input.is_action_just_released("place") and time_clicked > 0 and time_clicked < 0.2:
				if !rotating:
					object_settings.open_object(hovered_object)
			
			if Input.is_action_just_released("place") and rotating:
				rotating = false
				hovered_object.set_property("rotation_degrees", fmod(hovered_object.rotation_degrees, 360), true)
		
		if selected_box and selected_box.item:
			
			# Place items
		
			
			if left_held and selected_tool == 0:
				var item = selected_box.item
				
				
			
				
				if !item.is_object: # Place tile
					# Don't spam place tiles into the same spot
					if ((mouse_tile_pos != last_mouse_tile_pos or Input.is_action_just_pressed("place"))
						and item.on_place(mouse_tile_pos, level_data, level_area) and level_area.settings.bounds.has_point(mouse_tile_pos+Vector2(0.5,0.5))):
						var last_tile = shared.get_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer)
						
						if !(last_tile[0] == item.tileset_id and last_tile[1] == item.tile_id):
							tiles_stack.append([mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, last_tile, [item.tileset_id, item.tile_id]])
						
						shared.set_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, item.tileset_id, item.tile_id, item.palette_index)
				elif !is_instance_valid(hovered_object) and !rotating: # Place object
					var last_object_pos : Vector2
					
						
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
						shared.create_object(object, true)
						last_object_pos = object_pos
						
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
								tiles_stack.append([mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, last_tile, [0, 0]])
							
							shared.set_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, 0, 0)
			
			# Middle click tiles
			var item = selected_box.item
			if !item.is_object and Input.is_action_just_pressed("minecraft_pick_block"):
				var tile = shared.get_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer)
				pick_tile(tile)
			
			if selected_box.item.is_object and !rotating and time_clicked <= 0:
				update_selected_object(mouse_pos)
		
		# Finalise tile placement action (for potential future undo)
		if !left_held:
			time_clicked = 0
			if last_left_held or !right_held and last_right_held:
				var action = Action.new()
				action.type = "place_tile"
				for element in tiles_stack:
					action.data.append(element)
				tiles_stack.clear()
				Singleton.ActionManager.add_action(action)
				# if an action is being added, that means we should count the count the level data as modified and in need of a save
				Singleton.CurrentLevelData.unsaved_editor_changes = true
		
		
		last_mouse_pos = mouse_pos
		last_mouse_tile_pos = mouse_tile_pos
		last_left_held = left_held
		last_right_held = right_held
