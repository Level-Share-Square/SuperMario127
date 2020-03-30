extends Node2D

class_name GameObject

var mode := 0
var level_data = null
var level_area = null
var level_object = null

var enabled = true

var base_savable_properties : PoolStringArray = ["position", "scale", "rotation_degrees", "enabled", "visible"]
var savable_properties : PoolStringArray = []

var base_editable_properties : PoolStringArray = ["enabled", "visible", "rotation_degrees", "scale", "position"]
var editable_properties : PoolStringArray = []

var base_connectable_signals : PoolStringArray = ["ready", "process", "physics_process"]
var connectable_signals : PoolStringArray = []

signal process
signal physics_process

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

func set_property(key, value, change_level_object):
	self[key] = value
	if change_level_object and is_savable_property(key):
		var index = get_property_index(key)
		if index == level_object.properties.size():
			level_object.properties.append(value)
		else:
			level_object.properties[index] = value

func set_property_by_index(index, value, change_level_object):
	var key = (base_savable_properties + savable_properties)[index]
	set_property(key, value, change_level_object)
	
func _set_properties():
	pass
	
func _set_property_values():
	pass
	
func _process(delta):
	emit_signal("process")
	
func _physics_process(delta):
	emit_signal("physics_process")

func _init_signals():
	var index = 0
	for signal_name in (base_connectable_signals + connectable_signals):
		connect(signal_name, self, "on_signal_fire", [index])
		index += 1

func on_signal_fire(index):
	var mode = get_tree().get_current_scene().mode
	if mode == 0:
		var functions = level_object.player_signal_connections[index]
		for function_name in functions:
			var function_struct = level_data.functions[function_name]
			interpreter_util.run_function(function_struct, self)
	elif mode == 1:
		var functions = level_object.editor_signal_connections[index]
		for function_name in functions:
			var function_struct = level_data.functions[function_name]
			interpreter_util.run_function(function_struct, self)
