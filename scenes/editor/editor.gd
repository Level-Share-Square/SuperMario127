extends LevelDataLoader

const COIN_ANIM_FPS = 12
const LAYER_COUNT = 4

var mode = 1

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
onready var placeable_items_button_container : Sprite = get_node(placeable_items_button_container_path)
onready var item_preview : Sprite = get_node(item_preview_path)
onready var shared : Node2D = get_node(shared_path)
onready var object_settings : NinePatchRect = get_node(object_settings_path)

var lock_axis := "none"
var lock_pos := 0
var last_mouse_pos := Vector2(0, 0)
var last_mouse_tile_pos := Vector2(0, 0)

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

var rainbow_gradient_texture := GradientTexture.new()
var rainbow_gradient := Gradient.new()
var rainbow_hue := 0
var coin_frame : int

func _physics_process(delta):
	rainbow_hue += 0.0075 * delta * 120
	rainbow_gradient.offsets = PoolRealArray([0.15, 1])
	rainbow_gradient.colors = PoolColorArray([Color.from_hsv(rainbow_hue, 1, 1), Color(1, 1, 1)])
	rainbow_gradient_texture.gradient = rainbow_gradient


# Functions to avoid copy pasted code
func cap_zoom_level() -> void:
	# Reduce the zoom level if the screen wouldn't fit within the level
	# NOTE: all values are -6 since there are 3 tiles OOB in both directions for both axis
	var level_size : Vector2 = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.bounds.size
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
	
	cap_zoom_level(); # Make sure it's not too large
	
	zoom_level = level
	EditorSavedSettings.zoom_level = zoom_level

func add_zoom_level(level : float) -> void:
	set_zoom_level(zoom_level + level)

func get_shared_node() -> Node:
	return shared

func switch_layers() -> void:
	editing_layer = wrapi(editing_layer + 1, 0, LAYER_COUNT)
	EditorSavedSettings.layer = editing_layer
	
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
		ActionManager.undo()
	elif event.is_action_pressed("redo"):
		ActionManager.redo()
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
		EditorSavedSettings.layers_transparent = layers_transparent
		shared.toggle_layer_transparency(editing_layer, layers_transparent)

func _ready() -> void:
	var data = CurrentLevelData.level_data
	load_in(data, data.areas[CurrentLevelData.area])
	zoom_level = EditorSavedSettings.zoom_level
	editing_layer = EditorSavedSettings.layer
	layers_transparent = EditorSavedSettings.layers_transparent
	shared.toggle_layer_transparency(editing_layer, layers_transparent)
	
	# if the mode switch button is invisible then the editor hasn't been readyed for the first time yet
	# (editor _ready() gets called every time a mode switch happens)
	# if the button is invisible and we're in the editor scene, we know it's time to setup the editor for the first time
	if get_node("/root/mode_switcher/ModeSwitcherButton").invisible:
		# enable the mode switching button since we're using the editor
		get_node("/root/mode_switcher/ModeSwitcherButton").change_button_state(true)
		get_node("/root/music").play() # needed as the music no longer plays by default

		# make sure the mode switcher button is set to have the play button as it's visual
		mode_switcher.get_node("ModeSwitcherButton").change_visuals(0)
	
func set_selected_box(new_selected_box: Node) -> void:
	EditorSavedSettings.selected_box = new_selected_box.box_index
	item_preview.update_preview(new_selected_box.item)
	selected_box = new_selected_box
	for placeable_item_button in placeable_items_button_container.get_children():
		placeable_item_button.update_selection()

func switch_scenes() -> void:
	var _change_scene = get_tree().change_scene("res://scenes/player/player.tscn")

func update_selected_object(mouse_pos : Vector2) -> void:
	if selected_box.item.is_object and !rotating and time_clicked <= 0:
		var objects = shared.get_objects_overlapping_position(mouse_pos)
		if objects.size() > 0 and placement_mode != "Tile":
			if hovered_object != objects[0]:
				# If something was already hovered, mark it as not
				if hovered_object != null:
					hovered_object.modulate = Color(1, 1, 1, hovered_object.modulate.a)
					hovered_object.hovered = false
				
				hovered_object = objects[0]
				hovered_object.hovered = true
				hovered_object.modulate = Color(0.65, 0.65, 1, hovered_object.modulate.a)
				item_preview.visible = false
		elif hovered_object != null and is_instance_valid(hovered_object):
			hovered_object.modulate = Color(1, 1, 1, hovered_object.modulate.a)
			hovered_object.hovered = false
			hovered_object = null
			item_preview.visible = true

func _process(delta : float) -> void:
	# warning-ignore: integer_division
	coin_frame = (OS.get_ticks_msec() * COIN_ANIM_FPS / 1000) % 4
	
	# For some strange reason, setting it to null right after the object is created
	# causes issues, so wait a frame instead by placing the assignment over here
	placed_item_property = null
	
	cap_zoom_level(); # Make sure it didn't accidentally get larger somehow
	
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
		if hovered_object:
			if Input.is_action_just_pressed("rotate"):
				rotating = true
			
			if Input.is_action_just_pressed("flip_object"):
				hovered_object.set_property("scale", Vector2(-hovered_object.scale.x, hovered_object.scale.y), true)
			
			if Input.is_action_just_pressed("flip_object_v"):
				hovered_object.set_property("scale", Vector2(hovered_object.scale.x, -hovered_object.scale.y), true)
			
			if left_held and selected_tool == 0 and Input.is_action_just_pressed("place") and !rotating:
				if Input.is_action_pressed("duplicate"):
					var object := LevelObject.new()
					var original_object : LevelObject = hovered_object.level_object.get_ref()
					object.type_id = original_object.type_id
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
			
			if Input.is_action_just_pressed("place") and rotating:
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
						
						shared.set_tile(mouse_tile_pos.x, mouse_tile_pos.y, editing_layer, item.tileset_id, item.tile_id)
				elif hovered_object == null: # Place object
					var object_pos : Vector2
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
					if object_pos and !shared.is_object_at_position(object_pos) and item.on_place(object_pos, level_data, level_area):
						var object := LevelObject.new()
						object.type_id = item.object_id
						object.properties.append(object_pos)
						object.properties.append(Vector2(1, 1))
						object.properties.append(0)
						object.properties.append(true)
						object.properties.append(true)
						shared.create_object(object, true)
			
			# Delete items
			if (right_held and selected_tool < 2) or (left_held and selected_tool == 1):
				var item = selected_box.item
				if item.is_object: # Delete object
					if placement_mode == "Tile":
						var object_pos : Vector2 = (mouse_tile_pos * item.tile_mode_step) + item.object_center
						if item.on_erase(object_pos, level_data, level_area):
							shared.destroy_object_at_position(object_pos, true)
					elif (Input.is_action_just_pressed("erase") or Input.is_action_just_pressed("place") and selected_tool == 1) and hovered_object and !rotating:
						if item.on_erase(mouse_pos, level_data, level_area):
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
				ActionManager.add_action(action)
		
		
		last_mouse_pos = mouse_pos
		last_mouse_tile_pos = mouse_tile_pos
		last_left_held = left_held
		last_right_held = right_held
