class_name GameObject
extends Node2D

enum BasePropertyIDs {
	PALETTE = -2
	POSITION = -1
	SCALE = 0
	ROTATION = 1
	ENABLED = 2
	VISIBLE = 3
}

var bg_modulate := Color(0.54, 0.54, 0.54, modulate.a)
var selected_modulate := Color(0.7, 0.7, 1.2, modulate.a)
var hover_modulate := Color(modulate.r, modulate.g, modulate.b, 0.5)
var translucent_modulate := Color(0, 0, 0, 0.25)
var default_modulate := Color(1, 1, 1, modulate.a)
export var generate_editor_hitbox: bool = false

var global := {}
var editor_aliases := {}

var mode: int = 0
var object_data_ref: WeakRef = null
var level_layer_ref: WeakRef = null

var hovered: bool = false
var selected: bool = false
var translucent: bool = false

var loaded: bool = false

var enabled: bool = true
var preview_position := Vector2(72, 92)
var palette: int = 0
var palettes: int = 0

var z_layer: int = 0

# true if creating a GameObject for the object settings preview
var is_preview : bool = false

var visibility: bool = true # for modulate

var base_savable_properties: PoolStringArray = ["position", "scale", "rotation_degrees", "enabled", "visible"]
var base_hidden_properties: PoolStringArray = []
var savable_properties: PoolStringArray = []

var base_editable_properties: PoolStringArray = ["enabled", "visible", "rotation_degrees", "scale", "position"]
var editable_properties: PoolStringArray = []

var property_info: PoolStringArray = []

var property_value_to_name := {}
var property_value_menus := {}

onready var editor_hitbox: Area2D = get_node_or_null("EditorHitbox")

export var property_ids: Dictionary = {
	"palette": BasePropertyIDs.PALETTE,
	"position": BasePropertyIDs.POSITION,
	"scale": BasePropertyIDs.SCALE,
	"rotation_degrees": BasePropertyIDs.ROTATION,
	"enabled": BasePropertyIDs.ENABLED,
	"visible": BasePropertyIDs.VISIBLE
}


signal property_changed(key, value)
signal object_clicked(object)

export var internal_id: String
const PLACEABLE_ITEM_PATH: String = "res://scenes/editor/items/placeable_items/placeable_objects/%s.tres"
var placeable_item: PlaceableItem


func load_placeable_item():
	if ResourceLoader.exists(PLACEABLE_ITEM_PATH % internal_id):
		placeable_item = ResourceLoader.load(PLACEABLE_ITEM_PATH % internal_id)

func _init():
	property_ids = property_ids.duplicate()

func _ready():
	load_placeable_item()
	
	set_object_data_property_metadata()
	for property in savable_properties:
		property_ids.get_or_add(property, property_ids.values().size() - 2)
	
	if get_tree().current_scene.mode == 1:
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
		
#		if is_instance_valid(object_data_ref):
#			visibility = object_data_ref.get_ref().properties[4]
		
		editor_hitbox.collision_mask = 2
		var editor = get_tree().current_scene
		editor_hitbox.connect("mouse_entered", editor, "object_hovered", [self])
		editor_hitbox.connect("mouse_exited", editor, "object_unhovered", [self])
	else:
		if is_instance_valid(editor_hitbox):
			editor_hitbox.queue_free()
			
#	print(object_data_ref.get_ref().properties)
			
	set_object_properties_from_data()
	
	match mode:
		LevelPlayer.mode:
			call_deferred("_object_ready")
			
			if not enabled:
				call_deferred("_object_disabled_ready")
				return
			
			if is_on_ground_layer():
				call_deferred("_object_ground_ready")
			else:
				call_deferred("_object_parallax_ready")
		Editor.mode:
			call_deferred("_editor_ready")
	loaded = true

func _process(delta):
	match mode:
		LevelPlayer.mode:
			_object_process(delta)
			
			if not enabled:
				_object_disabled_process(delta)
				return
			
			if is_on_ground_layer():
				_object_ground_process(delta)
			else:
				_object_parallax_process(delta)
		Editor.mode:
			_editor_process(delta)


func _physics_process(delta):
	match mode:
		LevelPlayer.mode:
			_object_physics_process(delta)
			
			if not enabled:
				_object_disabled_physics_process(delta)
				return
			
			if is_on_ground_layer():
				_object_ground_physics_process(delta)
			else:
				_object_parallax_physics_process(delta)
		Editor.mode:
			_editor_physics_process(delta)


func _unhandled_input(event):
	if Input.is_action_just_pressed("click") and hovered and mode == Editor.mode:
		var editor = get_tree().current_scene
		connect("object_clicked", editor, "object_clicked", [self])
		emit_signal("object_clicked")


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


## run when the game object enters the scene tree
func _object_ground_ready() -> void:
	pass


## Run every process frame when the object is on a ground layer.
func _object_ground_process(delta: float) -> void:
	pass


## Run every physics frame when the object is on a ground layer.
func _object_ground_physics_process(delta: float) -> void:
	pass


## run when the game object enters the scene tree
func _object_parallax_ready() -> void:
	_object_disabled_ready()


## Run every process frame when the object is on a ground layer.
func _object_parallax_process(delta: float) -> void:
	_object_disabled_process(delta)


## Run every physics frame when the object is on a ground layer.
func _object_parallax_physics_process(delta: float) -> void:
	_object_disabled_physics_process(delta)


## run when the game object enters the scene tree
func _object_disabled_ready() -> void:
	enabled = false


## Run every process frame when the object is disabled.
func _object_disabled_process(delta: float) -> void:
	pass


## Run every physics frame when the object is disabled.
func _object_disabled_physics_process(delta: float) -> void:
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

func modulate_set():
	modulate = default_modulate
	
	if selected:
		modulate *= selected_modulate
	
	if hovered or not visibility:
		modulate.a = hover_modulate.a
		
	if translucent:
		modulate *= translucent_modulate

func set_object_properties_from_data() -> void:
	# silver you gotta clean this up
	var properties: Dictionary = {}
	for property in object_data_ref.get_ref().default_values:
		properties[property] = object_data_ref.get_ref().default_values[property]
		
	for property in object_data_ref.get_ref().properties:
		properties[property] = object_data_ref.get_ref().properties[property]
		
	for property in properties:
		if properties[property] != null:
			set_property_by_index(property, properties[property])

func set_object_data_property_metadata() -> void:
	if not is_instance_valid(object_data_ref):
		return
	
	var object_data: ObjectData = object_data_ref.get_ref()
	
	if is_instance_valid(object_data):
		object_data.property_ids = property_ids
		
		var property_id: int = -1
		for property in property_ids.keys():
			property_id = property_ids.get(property)
			if object_data.default_values.has(property_id):
				continue
			object_data.default_values[property_id] = self[property]


func is_savable_property(key) -> bool:
	for property in property_ids:
		if key == property:
			return true
	
	return false


func get_property_index(key) -> int:
	return property_ids[key]


func set_property(key, value, change_object_data = true, alias = null):
	if typeof(self[key]) != typeof(value):
		print("Object ", name, " tried to set property '" + key + "', but the provided type does not match.")
		return
	
	self[key] = value
	
	var object_data: ObjectData = object_data_ref.get_ref()
	
	if change_object_data and is_savable_property(key) and !is_preview:
		var id: int = property_ids.get(key, -1)
		if id < 0:
			return
		
		object_data.set_property(get_property_index(key), value)
		
		if key == "visible":
			if mode == 1:
				visible = true
				visibility = value
	
	if mode == 1 and !is_preview:
		emit_signal("property_changed", key, value)
		
func get_property(key):
	return object_data_ref.get_ref().get_property(get_property_index(key))


func get_editor_alias(key):
	return editor_aliases[key]


func has_editor_alias(key):
	for i in editor_aliases.keys():
		if i == key:
			return true
	return false


func set_property_by_index(index, value, change_level_object = true, alias = null):
	var key = property_ids.find_key(index)
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
	return level_layer_ref.get_ref() is LevelGroundLayer
	
func create_coin(coin_id, body, physics, velocity) -> void:
	var object := ObjectData.new(ObjectMetadata.new(
		body.global_position,
		coin_id,
		0
	))
	object.set_property_by_name("physics", physics)
	object.set_property_by_name("velocity", velocity)
	get_parent().create_object(object)
