extends Node2D

class_name GameObject

var global := {}
var editor_aliases := {}

var mode : int = 0
var level_data = null
var level_area = null
var level_object = null
var hovered := false
var camera: Camera2D

var enabled := true
var preview_position := Vector2(72, 92)
var palette := 0
var palettes := 0

var layer := 2
# translates layer var into a Z index
var layer_dictionary = {
	0: -11,
	1: -10,
	2: -1,
	3: 9
}
const BG_MODULATE := Color(0.54, 0.54, 0.54)
export var show_above_layer : bool = false

# true if creating a GameObject for the object settings preview
var is_preview : bool = false

var base_savable_properties : PoolStringArray = ["position", "scale", "rotation_degrees", "enabled", "visible", "layer"]
var savable_properties : PoolStringArray = []

var base_editable_properties : PoolStringArray = ["enabled", "visible", "rotation_degrees", "scale", "position", "layer"]
var editable_properties : PoolStringArray = []

var base_connectable_signals : PoolStringArray = ["ready", "process", "physics_process"]
var connectable_signals : PoolStringArray = []

var property_value_to_name := {}
var property_value_menus := {}

signal process
signal physics_process
signal property_changed(key, value)

var process_frame_counter = 0
var physics_frame_counter = 0

var has_process_connection = false
var has_physics_connection = false

export var help_menu_text := "Base help menu text."

func _ready():
	if visible == false and mode == 1:
		visible = true
		var color = modulate
		color.a = 0.5
		modulate = color
		
	
	if get_tree().current_scene.name == "Editor":
		var polygons: Array = []
		create_collision_polygons_from_tree(self, Transform2D.IDENTITY, polygons)
		
		if polygons.size() > 0:
			var hitbox := EditorHitbox.new()
			hitbox.name = "EditorHitbox"
			
			for polygon in polygons:
				hitbox.add_child(polygon)
			
			add_child(hitbox)
	set_property_menu("layer", ["option", 4, 0, ['Very Background', 'Background', 'Ground', 'Foreground']])
	update_layer()


func create_collision_polygons_from_tree(node: Node, node_transform: Transform2D, array: Array) -> void:
	if node is Sprite:
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(node.texture.get_data())
		
		var rect : Rect2
		if node.region_enabled:
			rect = node.region_rect
		else:
			rect.size = node.texture.get_size()
		
		var polygons: Array = bitmap.opaque_to_polygons(rect)
		for polygon in polygons:
			for i in range(polygon.size()):
				var point: Vector2 = polygon[i]
				point -= rect.position
				
				if node.flip_h:
					point.x = rect.size.x - point.x - 1.0
				if node.flip_v:
					point.y = rect.size.y - point.y - 1.0
				
				if node.centered:
					point -= rect.size / 2.0
				
				polygon[i] = point
			
			var collision_polygon := CollisionPolygon2D.new()
			collision_polygon.transform = node_transform.translated(node.offset)
			collision_polygon.polygon = polygon
			array.append(collision_polygon)
	
	for child in node.get_children():
		if child is Node2D:
			create_collision_polygons_from_tree(child, node_transform * child.transform, array)


func is_savable_property(key) -> bool:
	for savable_property in (base_savable_properties + savable_properties):
		if key == savable_property:
			return true
	
	return false


func get_property_index(key) -> int:
	var index = 0
	for savable_property in (base_savable_properties + savable_properties):
		if key == savable_property:
			return index
		index += 1
	return index


func set_property(key, value, change_level_object = true, alias = null):
	if typeof(self[key]) != typeof(value):
		assert("Object tried to set property '" + key + "', but the provided type does not match.")
		return
	
	self[key] = value
	if alias != null:
		editor_aliases[key] = alias
	if change_level_object and is_savable_property(key):
		var level_object_ref = level_object.get_ref()
		var index = get_property_index(key)
		if index == level_object_ref.properties.size():
			level_object_ref.properties.append(value)
		else:
			level_object_ref.properties[index] = value
		
		if key == "visible":
			if mode == 1:
				visible = true
				var color = modulate
				color.a = 0.5 if value == false else 1.0
				modulate = color
		elif key == "layer":
			update_layer()
			
	if mode == 1 and !is_preview:
		emit_signal("property_changed", key, value)


func get_editor_alias(key):
	return editor_aliases[key]


func has_editor_alias(key):
	for i in editor_aliases.keys():
		if i == key:
			return true
	return false


func set_property_by_index(index, value, change_level_object, alias = null):
	if (index < (base_savable_properties + savable_properties).size()):
		var key = (base_savable_properties + savable_properties)[index]
		set_property(key, value, change_level_object, alias)


func _set_properties():
	pass


func _set_property_values():
	pass


func _process(_delta):
	if has_process_connection:
		process_frame_counter -= 1
		if process_frame_counter <= 0:
			emit_signal("process")
			process_frame_counter = 4


func _physics_process(_delta):
	if has_physics_connection:
		physics_frame_counter -= 1
		if physics_frame_counter <= 0:
			emit_signal("physics_process")
			physics_frame_counter = 4


func _init_signals():
	var index = 0
	var level_object_ref = level_object.get_ref()
	if level_object_ref.player_signal_connections[index].size() > 0:
		for signal_name in (base_connectable_signals + connectable_signals):
			var _connect = connect(signal_name, self, "on_signal_fire", [index])
			index += 1
			if index < level_object_ref.player_signal_connections.size():
				if signal_name == "physics_process":
					if level_object_ref.player_signal_connections[index].size() > 0:
						has_physics_connection = true
				elif signal_name == "process":
					if level_object_ref.player_signal_connections[index].size() > 0:
						has_process_connection = true


func set_bool_alias(key, true_alias, false_alias):
	if true_alias != null && false_alias != null:
		property_value_to_name[key] = {true: true_alias, false: false_alias}
	else:
		printerr("Bool aliases for %s was not set!" % key)


func set_property_menu(key, menu_array: Array):
	if menu_array != null:
		property_value_menus[key] = menu_array
	else:
		printerr("Property menu for %s was not set!" % key)


func on_signal_fire(index):
	var current_mode = get_tree().get_current_scene().mode
	var level_object_ref = level_object.get_ref()
	if current_mode == 0:
		var functions = level_object_ref.player_signal_connections[index]
		for function_name in functions:
			var function_struct = level_data.functions[function_name]
			interpreter_util.run_function(function_struct, self)
	elif current_mode == 1:
		var functions = level_object_ref.editor_signal_connections[index]
		for function_name in functions:
			var function_struct = level_data.functions[function_name]
			interpreter_util.run_function(function_struct, self)


func update_layer():
	if layer <= 4:
		z_index = layer_dictionary[layer] + (1 * int(show_above_layer))
	else:
		printerr("Object has assigned layer %s" % layer)
		
	if layer == 0 or layer == 1:
		enabled = false
		modulate = BG_MODULATE
	else:
		modulate = Color(1, 1, 1)
	if layer == 3:
		enabled = false


func get_shared():
	return get_parent().get_parent()

#func is_mouse_over_window()-> bool:
#
#	var UI: CanvasLayer
#
#	# Get the Editor UI Node
#	if (get_parent().name != "Objects"):
#
#		UI = get_tree().root.get_node_or_null("Editor/UI")
#
#	else:
#
#		UI = get_parent().get_parent().get_parent().get_node_or_null("UI")
#
#	if (UI == null):
#		return true
#
#	# Get all the potentially open windows
#	var quit_wo_saving_window: Popup = UI.get_node("BackButton").get_node("QuitWOSavingWindow")
#	var level_settings_window: NinePatchRect = UI.get_node("LevelSettingsWindow")
#	var object_settings_window: NinePatchRect = UI.get_node("ObjectSettingsWindow")
#	var level_code_window: NinePatchRect = UI.get_node("LevelCodeWindow") # Not currently used
#	var areas_window: NinePatchRect = UI.get_node("AreasWindow")
#	var colour_picker_window: NinePatchRect = UI.get_node("ColorPickerWindow")
#	var help_window: NinePatchRect = UI.get_node("HelpWindow")
#	var auto_save_window: NinePatchRect = UI.get_node("AutosaveWINDOW")
#
#	var windows: Array = [quit_wo_saving_window,level_settings_window,object_settings_window,
#		areas_window,colour_picker_window,help_window,auto_save_window]
#
#	for window in windows:
#
#		if (window.hovered and window.visible):
#			return true
#
#	return false
#
#func is_mouse_over_area() -> bool:
#
#	# Get the Editor UI Node
#	var UI: CanvasLayer = get_parent().get_parent().get_parent().get_node_or_null("UI")
#
#	if !is_instance_valid(UI):
#
#		UI = get_parent().get_parent().get_parent().get_parent()
#		if !is_instance_valid(UI):
#			return true
#
#	# Get all the potential overlapping areas
#	var placeable_items_container: TextureRect = UI.get_node("PlaceableItemsContainer")
#	var item_picker: TextureRect = UI.get_node("ItemPicker")
#	var item_picker_bottom: TextureRect
#	var item_picker_close_button: Button
#	if (item_picker.visible):
#
#		item_picker_bottom = item_picker.get_node("Bottom")
#		item_picker_close_button = item_picker.get_node("CloseButton")
#
#	var areas: Array = [placeable_items_container,item_picker,item_picker_bottom,item_picker_close_button]
#
#	for area in areas:
#
#		if !is_instance_valid(area) or !area.visible: # Don't check for areas that aren't visible
#			continue
#
#		if area.hovered:
#			return true
#
#	# none of the areas are currently hovered over
#	return false

func parts_input_handler(event, object):
#	if is_mouse_over_window() or is_mouse_over_area():
#		return
	
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			object.parts -= 1
			if object.parts < 1:
				object.parts = 1
			object.set_property("parts", object.parts, true)
			object.update_parts()
		elif event.button_index == 4: # Mouse wheel up
			object.parts += 1
			object.set_property("parts", object.parts, true)
			object.update_parts()

func get_sprite_size(body)-> Vector2:
	
	var sprite_base = body.find_node("Sprite") # Most static image objects
	if (!is_instance_valid(sprite_base)):
		sprite_base = body.find_node("AnimatedSprite")
	if (!is_instance_valid(sprite_base)): # NPC check
		sprite_base = body.find_node("Body")
	if (!is_instance_valid(sprite_base)): # For only fludd nozzle objects
		match body.nozzle_type:
			"HoverNozzle":
				sprite_base = body.get_node("Sprite_HoverNozzle")
			"TurboNozzle":
				sprite_base = body.get_node("Sprite_TurboNozzle")
			"RocketNozzle":
				sprite_base = body.get_node("Sprite_RocketNozzle")
	
	if (sprite_base is AnimatedSprite): # Animated objects
		var body_sprites: AnimatedSprite = sprite_base
		var body_anim: SpriteFrames = body_sprites.frames
		var body_texture: Texture = body_anim.get_frame(body_sprites.animation,body_sprites.frame)
		
		return body_texture.get_size()
	
	# Static image objects
	var body_sprite: Sprite = sprite_base
	var body_texture: Texture = body_sprite.texture
	
	return body_texture.get_size()

func is_on_screen(body)-> bool:
	
	var sprite_size: Vector2 = get_sprite_size(body)
	var sprite_width: float = sprite_size.x
	var sprite_height: float = sprite_size.y
	
	var root: Viewport = get_tree().root
	var editor = root.get_node_or_null("Editor")
	var is_editor: bool = is_instance_valid(editor)
	
	if (is_editor):
		camera = editor.camera # editor camera
	else:
		camera = root.get_node("Player").get_node_or_null("CameraP1") # gameplay camera
	
	if (!is_instance_valid(camera)):
		# If you're playing multiplayer this doesn't work and I'm not
		# going to try to make it work :)
		return true
	
	# offset the camera position by this much so that it acts as if
	# being in the top-left is -96,-96
	var width_offset: int = 288 + 96
	var height_offset: int = 50 + 96 if is_editor else 50 + 166
	
	var camera_width: float = 786 * camera.scale.x
	var camera_height: float = 432 * camera.scale.y
	
	var camera_pos: Vector2 = camera.get_camera_screen_center() - Vector2(width_offset,height_offset)
	
#	print(camera_pos," ",position)
	
	if (position.x + sprite_width < camera_pos.x or # Object off left side of screen
	position.y + sprite_height < camera_pos.y or # Object off top of screen
	position.x - sprite_width > camera_pos.x + camera_width or # Object off right side of screen
	position.y - sprite_height > camera_pos.y + camera_height): # Object off bottom of screen
		return false
	
	return true
