class_name MethodExecution

var id := "MTE"
var path := []
var args = []

func get_value(environment: InterpreterEnvironment):
	var args_used = args.duplicate(true)
	
	var parent_key = interpreter_util.get_path_parent_key(path, environment)
	var object = parent_key[0]
	var method_name = parent_key[1]
	
	var index = 0
	for arg in args_used:
		args_used[index] = interpreter_util.decode_var(arg, environment)
		index += 1
	return object.callv(method_name, args_used)

func get_class():
	return "InterpreterVar"
