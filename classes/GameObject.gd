extends Node2D

class_name GameObject

var global := {}

var mode := 0
var level_data = null
var level_area = null
var level_object = null
var hovered := false

var enabled = true
var preview_position := Vector2(72, 92)

var base_savable_properties : PoolStringArray = ["position", "scale", "rotation_degrees", "enabled", "visible"]
var savable_properties : PoolStringArray = []

var base_editable_properties : PoolStringArray = ["enabled", "visible", "rotation_degrees", "scale", "position"]
var editable_properties : PoolStringArray = []

var base_connectable_signals : PoolStringArray = ["ready", "process", "physics_process"]
var connectable_signals : PoolStringArray = []

signal process
signal physics_process
signal property_changed(key, value)

var process_frame_counter = 0
var physics_frame_counter = 0

var has_process_connection = false
var has_physics_connection = false

func _ready():
	if visible == false and mode == 1:
		visible = true
		var color = modulate
		color.a = 0.5
		modulate = color

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

func set_property(key, value, change_level_object = true):
	self[key] = value
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
	if mode == 1:
		emit_signal("property_changed", key, value)
				

func set_property_by_index(index, value, change_level_object):
	var key = (base_savable_properties + savable_properties)[index]
	set_property(key, value, change_level_object)
	
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
