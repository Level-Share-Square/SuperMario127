class_name interpreter_util

static func run_function(function_struct: FunctionStruct, object):
	var environments = []
	var global_environment = InterpreterEnvironment.new()
	global_environment.object = object
	environments.append(global_environment)
	
	var highest_available_scope = 0
	
	for instruction in function_struct.instructions:
		instruction.scope = highest_available_scope
		var return_code = instruction.execute(environments[highest_available_scope])
		if return_code == 1:
			# execute next scope
			highest_available_scope += 1
			var environment = InterpreterEnvironment.new()
			environment.object = object
			environment.parent = environments[highest_available_scope - 1]
			environment.scope = highest_available_scope
			environments.append(environment)
		elif return_code == 2:
			# exit current scope
			var current_scope = environments[highest_available_scope]
			environments.erase(current_scope)
			highest_available_scope -= 1

static func decode_var(possible_var, environment: InterpreterEnvironment):
	if typeof(possible_var) == TYPE_OBJECT:
		if possible_var.get_class() == "InterpreterVar" or possible_var.get_class() == "InterpreterCondition":
			var value = possible_var.get_value(environment)
			if typeof(possible_var) == TYPE_OBJECT and possible_var.get_class() == "InterpreterVar" or possible_var.get_class() == "InterpreterCondition":
				return decode_var(value, environment)
			else:
				return value
		return possible_var
	return possible_var

static func get_path_value(path, environment: InterpreterEnvironment):
	var object = environment
	for key in path:
		if typeof(object) == TYPE_DICTIONARY:
			if object.has(key):
				object = object[key]
			else:
				object = null
				break
		else:
			object = object[key]
	
	if object == null and environment.parent:
		return get_path_value(path, environment.parent)
	else:
		return object

static func get_path_parent_key(path, environment: InterpreterEnvironment):
	var path_used = path.duplicate()
	var key = path_used[path_used.size() - 1]
	path_used.erase(key)
	var object = environment
	for other_key in path_used:
		object = object[other_key]
		
	return [object, key]

static func get_scope_name(environment: InterpreterEnvironment):
	return "scope" + str(environment.scope_level)
