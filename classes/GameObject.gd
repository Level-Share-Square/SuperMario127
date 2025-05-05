extends Node2D

class_name GameObject

var global := {}
var editor_aliases := {}

var mode: int = 0
var level_data = null
var level_area = null
var level_object: WeakRef = null
var hovered := false
var shared: LevelShared = null

var enabled := true
var preview_position := Vector2(72, 92)
var palette := 0
var palettes := 0

export(LevelShared.Layers) var default_layer: int = 3
export var layer_shift: int = 0
export var lock_layer: bool = false
export var ignore_layer_disabling: bool = false

var layer: int = 3
var z_layer: int = 0

const BG_MODULATE := Color(0.54, 0.54, 0.54)

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
	
	print("From object, ", level_object)
	
	if layer != default_layer and lock_layer:
		set_property("layer", default_layer, true)
	
	z_layer = layer + LevelShared.layer_index_offset
	
	if get_tree().current_scene.name == "Editor":
		var polygons: Array = []
		create_collision_polygons_from_tree(self, Transform2D.IDENTITY, polygons)
		
		if polygons.size() > 0:
			var hitbox := EditorHitbox.new()
			hitbox.name = "EditorHitbox"
			
			for polygon in polygons:
				hitbox.add_child(polygon)
			
			add_child(hitbox)
	
	if lock_layer:
		set_property_menu("layer", ["option", 1, layer, ['Way Background', 'Very Background', 'Background', 'Ground', 'Foreground', 'Very Foreground']])
	else:
		set_property_menu("layer", ["option", 6, 0, ['Way Background', 'Very Background', 'Background', 'Ground', 'Foreground', 'Very Foreground']])
	
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
	
	if change_level_object and is_savable_property(key) and !is_preview:
		var level_object_ref = level_object.get_ref()
		var index: int = get_property_index(key)
		
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
	if layer <= 5:
		z_layer = layer + LevelShared.layer_index_offset
		z_index = (z_layer * LevelShared.layer_spacing) + layer_shift
	else:
		printerr("Object has assigned layer %s" % layer)
	
	if layer < LevelShared.Layers.Middle:
		modulate = BG_MODULATE
	else:
		modulate = Color(1, 1, 1)
	
	if layer != default_layer:
		set_property("enabled", ignore_layer_disabling, true)


func parts_input_handler(event, object):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		match event.button_index:
			BUTTON_WHEEL_UP: # Mouse wheel up
				object.parts += 1
				object.set_property("parts", object.parts, true)
				object.update_parts()
			
			BUTTON_WHEEL_DOWN: # Mouse wheel down
				object.parts -= 1
				if object.parts < 1:
					object.parts = 1
				object.set_property("parts", object.parts, true)
				object.update_parts()

