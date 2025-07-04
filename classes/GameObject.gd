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

onready var editor_hitbox: Area2D = get_node_or_null("EditorHitbox")


func _ready():
	if visible == false and mode == 1:
		visible = true
		var color = modulate
		color.a = 0.5
		modulate = color
	
#	print("From object, ", level_object)
	
	if layer != default_layer and lock_layer:
		set_property("layer", default_layer, true)
	
	z_layer = layer + LevelShared.layer_index_offset
	
	
	if get_tree().current_scene.mode == 1:
		if not is_instance_valid(editor_hitbox):
			var editor_hitbox = Area2D.new()
			editor_hitbox.name = "EditorHitbox"
			editor_hitbox.monitorable = false
			editor_hitbox.monitoring = false
			add_child(editor_hitbox)
			
			var collision_shape = CollisionShape2D.new()
			collision_shape.shape = RectangleShape2D.new()
			editor_hitbox.add_child(collision_shape)
		
		if is_instance_valid(editor_hitbox):
			var editor = get_tree().current_scene
			editor_hitbox.connect("mouse_entered", editor, "object_hovered", [self])
			editor_hitbox.connect("mouse_exited", editor, "object_unhovered", [self])
	else:
		editor_hitbox.queue_free()
	
	if lock_layer:
		set_property_menu("layer", ["option", 1, layer, ['Way Background', 'Very Background', 'Background', 'Ground', 'Foreground', 'Very Foreground']])
	else:
		set_property_menu("layer", ["option", 6, 0, ['Way Background', 'Very Background', 'Background', 'Ground', 'Foreground', 'Very Foreground']])
	
	update_layer()


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
