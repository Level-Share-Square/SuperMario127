class_name GameObject
extends Node2D

enum BasePropertyIDs {
	IN_FRONT = -3
	PALETTE = -2
	POSITION = -1
	SCALE = 0
	ROTATION = 1
	ENABLED = 2
	VISIBLE = 3
}

const EDITOR_INVISIBLE_ALPHA: float = 0.25
const EDITOR_RECT_DRAW_COLOR: Color = Color(0.039216, 0.196078, 0.815686, 0.705882)


export var editor_rect: Rect2 = Rect2(-8, -8, 16, 16)
export var preview_position := Vector2(72, 92)

var mode: int = 0
var object_data: ObjectData = null
var level_layer_ref: WeakRef = null

var selected: bool = false
var translucent: bool = false

var loaded: bool = false
var palettes: int = 0

var in_front: bool = false
var enabled: bool = true
var palette: int = 0

# true if creating a GameObject for the object settings preview
var is_preview : bool = false

var visibility: bool = true # for modulate

var property_info: PoolStringArray = []

var property_value_to_name := {}
var property_value_menus := {}

var property_ids: Dictionary = {
	BasePropertyIDs.IN_FRONT: "in_front",
	BasePropertyIDs.PALETTE: "palette",
	BasePropertyIDs.POSITION: "position",
	BasePropertyIDs.SCALE: "scale",
	BasePropertyIDs.ROTATION: "rotation_degrees",
	BasePropertyIDs.ENABLED: "enabled",
	BasePropertyIDs.VISIBLE: "visible"
}

var property_defaults: Dictionary = {
	"in_front": false,
	"palette": 0,
	"scale": Vector2.ONE,
	"rotation_degrees": 0,
	"enabled": true,
	"visible": true
}

var editable_properties: PoolStringArray = []

onready var editor_hitbox: Area2D = get_node_or_null("EditorHitbox")


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
	_register_properties()
	
	load_placeable_item()
	
	set_process(true)
	set_physics_process(true)


func _process(delta: float) -> void:
	update()


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		if mode == LevelPlayer.mode:
			_object_ready()
		elif mode == Editor.mode:
			_editor_ready()
	elif what == NOTIFICATION_PROCESS:
		var delta: float = get_process_delta_time()
		if mode == LevelPlayer.mode:
			_object_process(delta)
		elif mode == Editor.mode:
			_editor_process(delta)
	elif what == NOTIFICATION_PHYSICS_PROCESS:
		var delta: float = get_physics_process_delta_time()
		if mode == LevelPlayer.mode:
			_object_physics_process(delta)
		elif mode == Editor.mode:
			_editor_physics_process(delta)


func _unhandled_input(event):
	if event.is_action_pressed("click") and is_object_hovered():
		var editor = get_tree().current_scene
		connect("object_clicked", editor, "object_clicked", [self])
		emit_signal("object_clicked")


func _draw() -> void:
	if is_object_hovered():
		draw_rect(editor_rect, EDITOR_RECT_DRAW_COLOR)


## Run when all objects are loaded.
func _level_loaded() -> void:
	pass


## run when the game object enters the scene tree
func _object_ready() -> void:
	pass


## Run every process frame in the LevelPlayer.
func _object_process(delta: float) -> void:
	pass


## Run every physics frame in the LevelPlayer.
func _object_physics_process(delta: float) -> void:
	pass


## run when the game object enters the scene tree in the editor
func _editor_ready() -> void:
	pass


## Run every process frame in the editor.
func _editor_process(delta: float) -> void:
	pass


## Run every physics frame in the editor.
func _editor_physics_process(delta: float) -> void:
	pass


func _register_properties():
	pass


func is_savable_property(key: String) -> bool:
	for property in property_ids:
		if key == property:
			return true
	
	return false


func get_property_index(property: String) -> int:
	return property_ids.find_key(property)


func register_property(id: int, property: String, default_value, editable: bool = true) -> void:
	if typeof(self[property]) != typeof(default_value):
		printerr("Object ", name, " tried to register property \"" + property + "\", but the provided type does not match.")
		return
	
	if id in property_ids.keys():
		return
	
	if property in property_ids.values():
		return
	
	self[property] = default_value
	
	property_ids.get_or_add(id, property)
	property_defaults.get_or_add(property, default_value)


func set_object_data(data: ObjectData) -> void:
	object_data = data
	
	for id in property_ids.keys():
		set_property_by_id(id, object_data.properties[id], false)


func set_property_by_id(property_id: int, value, change_object_data: bool = false) -> void:
	set_property(property_ids[property_id], value, change_object_data)


func set_property(property: String, value, change_object_data = false):
	if typeof(self[property]) != typeof(value):
		print("Object ", name, " tried to set property \"" + property + "\", but the provided type does not match.")
		return
	
	self[property] = value
	
	if change_object_data:
		var id: int = property_ids.find_key(property)
		
		if value != property_defaults.get(property):
			object_data.set_property(id, value)
		
		if property == "visible":
			if mode == 1:
				visible = true
				visibility = value
		
		if property == "in_front" and value == true:
			z_index = 1
		else:
			z_index = 0
	
	if mode == 1 and !is_preview:
		emit_signal("property_changed", property, value)


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
	if event is InputEventMouseButton and event.is_pressed() and is_object_hovered():
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


func is_enabled() -> bool:
	return enabled


func is_in_editor() -> bool:
	return mode == Editor.mode


func is_object_hovered() -> bool:
	return is_in_editor() and editor_rect.has_point(get_local_mouse_position())


func create_coin(coin_id, body, physics, velocity) -> void:
	var object := ObjectData.new(ObjectMetadata.new(
		body.global_position,
		coin_id,
		0
	))
	object.set_property_by_name("physics", physics)
	object.set_property_by_name("velocity", velocity)
	get_parent().create_object(object)


func create_object(pos: Vector2, object_id: int, palette: int):
	var level_layer: LevelLayer = level_layer_ref.get_ref()
	
	return level_layer.add_object(
		ObjectData.new(
			ObjectMetadata.new(
				pos,
				object_id,
				palette
			)
		)
	)
