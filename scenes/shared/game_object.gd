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
const EDITOR_RECT_DRAW_COLOR: Color = Color(0.039216, 0.196078, 0.815686, 0.8)

const EDITOR_HOVER_ALPHA: float = 0.5
const EDITOR_SELECT_COLOR: Color = Color(0.6, 0.6, 1)


export var editor_rect: Rect2 = Rect2(-8, -8, 16, 16)
export var preview_position := Vector2(72, 92)

var mode: int = 0
var object_data: ObjectData = null
var level_layer_ref: WeakRef = null

var selected: bool = false
var translucent: bool = false

var loaded: bool = false
var palettes: int = 0
var disabled_icon: TextureRect

var in_front: bool = false
var enabled: bool = true
var palette: int = 0

var is_on_ground = null setget ,is_on_ground_layer

# true if creating a GameObject for the object settings preview
var is_preview : bool = false

var visibility: bool = true # for modulate

var property_info: PoolStringArray = []

var property_overrides: Dictionary

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
	"rotation_degrees": 0.0,
	"enabled": true,
	"visible": true
}

var editable_properties: PoolStringArray = []
var base_hidden_properties: PoolStringArray = []
var property_tabs: PoolStringArray = []

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
	
	set_process(true)
	set_physics_process(true)

func _ready():
	_register_properties()
	load_placeable_item()
	set_object_data(object_data)
	instance_disabled_icon()
	if internal_id == "level_entrance_luigi":
		queue_free()
	
	if not visible and mode == Editor.mode:
		visible = true
		visibility = false

func _process(delta: float) -> void:
	if is_in_editor():
		_update_modulate_editor(delta)


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


func _update_modulate_editor(delta: float) -> void:
	if selected:
		var alpha = modulate.a
		modulate = modulate.linear_interpolate(EDITOR_SELECT_COLOR, delta * 16)
		modulate.a = alpha
	else:
		var alpha = modulate.a
		modulate = modulate.linear_interpolate(Color.white, delta * 16)
		modulate.a = alpha
	
	if is_object_hovered():
		modulate.a = lerp(modulate.a, EDITOR_HOVER_ALPHA, delta * 16)
	else:
		modulate.a = lerp(modulate.a, 1, delta * 16)
		
	if not visibility:
		modulate.a = lerp(modulate.a, EDITOR_INVISIBLE_ALPHA, delta * 16)
	else:
		modulate.a = lerp(modulate.a, 1, delta * 16)
		
	disabled_icon.visible = (!enabled and is_in_editor())
	if disabled_icon.visible: disabled_icon.rect_position = Vector2((global_transform.xform(editor_rect)).size.x + (global_transform.xform(editor_rect)).position.x, (global_transform.xform(editor_rect)).position.y) - disabled_icon.texture.get_size()/2


## Run when all objects are loaded.
func _level_loaded() -> void:
	pass


## run when the game object enters the scene tree
func _object_ready() -> void:
	if !is_on_ground_layer():
		enabled = false


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


func _object_removed(free: bool) -> void:
	pass


func _object_restored() -> void:
	pass


func _register_properties():
	pass


func is_savable_property(key: String) -> bool:
	for property in property_ids.values():
		if key == property:
			return true
	
	return false


func get_property_index(property: String) -> int:
	return property_ids.find_key(property)


func get_data_property(property: String):
	var data_property = object_data.get_property(get_property_index(property))
	if data_property == null:
		data_property = property_defaults.get(property)
	return data_property


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
	
	if editable:
		editable_properties.append(property)


func set_object_data(data: ObjectData) -> void:
	object_data = data
	for id in object_data.properties:
		set_property_by_id(id, object_data.properties[id], false)


func set_property_by_id(property_id: int, value, change_object_data: bool = false) -> void:
	if property_ids.has(property_id):
		set_property(property_ids[property_id], value, change_object_data)


func set_property(property: String, value, change_object_data = false):
	if typeof(self[property]) != typeof(value):
		printerr("Object ", name, " tried to set property \"" + property + "\", but the provided type does not match.")
		return

	self[property] = value
	
	if change_object_data:
		var id: int = property_ids.find_key(property)

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
#	if true_alias != null && false_alias != null:
#		property_value_to_name[key] = {true: true_alias, false: false_alias}
#	else:
#		printerr("Bool aliases for %s was not set!" % key)
	pass


func set_property_menu(key, menu_array: Array):
#	if menu_array != null:
#		property_value_menus[key] = menu_array
#	else:
#		printerr("Property menu for %s was not set!" % key)
	pass
		
func set_property_override(property: String, type: int, args):
	print(property)
	property_overrides.get_or_add(property, [type, [property, args]])


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
	if not typeof(is_on_ground) == TYPE_BOOL:
		is_on_ground = level_layer_ref.get_ref() is LevelGroundLayer
	
	return is_on_ground


func is_enabled() -> bool:
	return enabled


func is_enabled_and_on_parallax() -> bool:
	return is_enabled() and not is_on_ground_layer()


func is_enabled_and_on_ground() -> bool:
	return is_enabled() and is_on_ground_layer()


func is_disabled_and_on_ground() -> bool:
	return not is_enabled() and is_on_ground_layer()


func is_disabled_and_on_parallax() -> bool:
	return not is_enabled() and not is_on_ground_layer()


func is_in_editor() -> bool:
	return mode == Editor.mode

func is_object_hovered() -> bool:
	if is_in_editor():
		var editor = get_tree().current_scene
		if editor.layer == level_layer_ref.get_ref().layer_data.layer_metadata.layer_uuid and editor.selected_item is PlaceableObject and editor_rect.has_point(get_local_mouse_position()):
			return true
	return false

func get_global_editor_rect() -> Rect2:
	return get_global_transform().xform(editor_rect)

func create_coin(coin_id: int, body: Node2D, physics: bool, velocity: Vector2) -> void:
	var object = create_object(body.global_position, coin_id, 0)
	object.set_property("physics", physics)
	object.set_property("velocity", velocity)


func create_object(pos: Vector2, object_id: int, palette: int):
	var level_layer: LevelLayer = level_layer_ref.get_ref()
	
	return level_layer.setup_object(
		ObjectData.new(
			ObjectMetadata.new(
				pos,
				object_id,
				palette
			)
		)
	)

func instance_disabled_icon():
	disabled_icon = TextureRect.new()
	disabled_icon.texture = Singleton.MiscCache.disabled_icon
	disabled_icon.rect_position = Vector2(editor_rect.size.x + editor_rect.position.x, editor_rect.position.y) - disabled_icon.texture.get_size()/2
	disabled_icon.set_as_toplevel(true)
	disabled_icon.hide()
	add_child(disabled_icon)
