class_name GameObject
extends Node2D


var bg_modulate := Color(0.54, 0.54, 0.54, modulate.a)
var selected_modulate := Color(0.7, 0.7, 1.2, modulate.a)
var hover_modulate := Color(modulate.r, modulate.g, modulate.b, 0.5)
var translucent_modulate := Color(0, 0, 0, 0.25)
var default_modulate := Color(1, 1, 1, modulate.a)

export(LevelShared.Layers) var default_layer: int = LevelShared.Layers.Middle
export var layer_shift: int = 0
export var lock_layer: bool = false
export var ignore_layer_disabling: bool = false
export var generate_editor_hitbox: bool = false

var global := {}
var editor_aliases := {}

var mode: int = 0
var level_data: LevelData = null
var level_area: LevelArea = null
var level_object: WeakRef = null
var shared: LevelShared = null

var hovered: bool = false
var selected: bool = false
var translucent: bool = false

var loaded: bool = false

var enabled: bool = true
var preview_position := Vector2(72, 92)
var palette: int = 0
var palettes: int = 0

var layer: int = LevelShared.Layers.Middle
var z_layer: int = 0

# true if creating a GameObject for the object settings preview
var is_preview : bool = false

var visibility: bool = true # for modulate

var base_savable_properties: PoolStringArray = ["position", "scale", "rotation_degrees", "enabled", "visible", "layer"]
var base_hidden_properties: PoolStringArray = []
var savable_properties: PoolStringArray = []

var base_editable_properties: PoolStringArray = ["enabled", "visible", "rotation_degrees", "scale", "position", "layer"]
var editable_properties: PoolStringArray = []

var property_info: PoolStringArray = []

var property_value_to_name := {}
var property_value_menus := {}

onready var editor_hitbox: Area2D = get_node_or_null("EditorHitbox")


signal property_changed(key, value)
signal object_clicked(object)

export var internal_id: String
const PLACEABLE_ITEM_PATH: String = "res://scenes/editor/items/placeable_items/placeable_objects/%s.tres"
var placeable_item: PlaceableItem


func load_placeable_item():
	placeable_item = load(PLACEABLE_ITEM_PATH % internal_id)


func _ready():
	load_placeable_item()
	
	if layer != default_layer and lock_layer:
		set_property("layer", default_layer, true)
	
	z_layer = layer + LevelShared.layer_index_offset
	
	if get_tree().current_scene.mode == 1:
		if is_instance_valid(level_object):
			shared.get_node("%Layers").connect("layer_changed", self, "_on_layer_changed")
		if generate_editor_hitbox:
			if is_instance_valid(editor_hitbox):
				editor_hitbox.queue_free()
			
			editor_hitbox = Area2D.new()
			editor_hitbox.name = "EditorHitbox"
			editor_hitbox.monitorable = false
			editor_hitbox.monitoring = false
			add_child(editor_hitbox)
			
			var polygons: Array = []
			create_collision_polygons_from_tree(self, Transform2D.IDENTITY, polygons)
			
			for polygon in polygons:
				editor_hitbox.add_child(polygon)
			
		elif not is_instance_valid(editor_hitbox):
			editor_hitbox = Area2D.new()
			editor_hitbox.name = "EditorHitbox"
			editor_hitbox.monitorable = false
			editor_hitbox.monitoring = true
			add_child(editor_hitbox)
			
			var collision_shape = CollisionShape2D.new()
			collision_shape.shape = RectangleShape2D.new()
			editor_hitbox.add_child(collision_shape)
		
		if is_instance_valid(level_object):
			visibility = level_object.get_ref().properties[4]
		
		var editor = get_tree().current_scene
		editor_hitbox.connect("mouse_entered", editor, "object_hovered", [self])
		editor_hitbox.connect("mouse_exited", editor, "object_unhovered", [self])
		if enabled == true:
			editor_hitbox.connect("area_entered", editor.selection_box.get_parent(), "_on_object_entered", [self])
			editor_hitbox.connect("area_exited", editor.selection_box.get_parent(), "_on_object_exited", [self])
	else:
		if is_instance_valid(editor_hitbox):
			editor_hitbox.queue_free()
	
	update_layer()
	
	yield(get_tree(), "idle_frame")
	
	property_info.resize(editable_properties.size())
	
	match mode:
		LevelPlayer.mode:
			_object_ready()
			
			if loaded:
				_level_loaded()
		Editor.mode:
			_editor_ready()
			
			if loaded:
				_editor_loaded()


func _process(delta):
	match mode:
		LevelPlayer.mode:
			_object_process(delta)
			
			if is_on_ground_layer():
				_object_logic_process(delta)
		Editor.mode:
			_editor_process(delta)


func _physics_process(delta):
	match mode:
		LevelPlayer.mode:
			_object_physics_process(delta)
			
			if is_on_ground_layer():
				_object_logic_physics_process(delta)
		Editor.mode:
			_editor_physics_process(delta)


func _unhandled_input(event):
	if Input.is_action_just_pressed("click") and hovered and mode == Editor.mode:
		var editor: Editor = get_tree().current_scene
		connect("object_clicked", editor, "object_clicked", [self])
		emit_signal("object_clicked")
	
	modulate_set()


## run when the game object enters the scene tree
func _object_ready() -> void:
	pass


## Run when all objects are loaded.
func _level_loaded() -> void:
	pass


## Run every process frame in the LevelPlayer.
func _object_process(delta: float) -> void:
	pass


## Run every physics frame in the LevelPlayer.
func _object_physics_process(delta: float) -> void:
	pass


## Run every process frame when the object is on the ground layer.
func _object_logic_process(delta: float) -> void:
	pass


## Run every physics frame when the object is on the ground layer.
func _object_logic_physics_process(delta: float) -> void:
	pass


## run when the game object enters the scene tree in the editor
func _editor_ready() -> void:
	pass


## Run when all objects are loaded in the editor.
func _editor_loaded() -> void:
	pass


## Run every process frame in the editor.
func _editor_process(delta: float) -> void:
	pass


## Run every physics frame in the editor.
func _editor_physics_process(delta: float) -> void:
	pass


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


func modulate_set():
	modulate = default_modulate
	
	if selected:
		modulate *= selected_modulate
	
	if layer < LevelShared.Layers.Middle:
		modulate *= bg_modulate
	
	if hovered or not visibility:
		modulate.a = hover_modulate.a
		
	if translucent:
		modulate *= translucent_modulate


func set_property(key, value, change_level_object = true, alias = null):
	if typeof(self[key]) != typeof(value):
		assert("Object tried to set property '" + key + "', but the provided type does not match.")
		return
	
	self[key] = value
	
	var object_data = level_object.get_ref()
	
	if change_level_object and is_savable_property(key) and !is_preview:
		var index: int = get_property_index(key)
		
		if index == object_data.properties.size():
			object_data.properties.append(value)
		else:
			object_data.properties[index] = value
		
		if key == "visible":
			if mode == 1:
				visible = true
				visibility = value
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


func update_layer():
	if layer <= 3:
		z_layer = layer + LevelShared.layer_index_offset
		z_index = (z_layer * LevelShared.layer_spacing) + layer_shift
	else:
		printerr("Object has assigned layer %s" % layer)


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


func is_on_ground_layer() -> bool:
	return true


func _on_layer_changed(new_layer):
	if new_layer != layer && shared.get_parent().show_layers:
		translucent = true
	else:
		translucent = false


func recursive_find_shared(node):
	if node.name == "Shared":
		return node
	else:
		return recursive_find_shared(node.get_parent())
