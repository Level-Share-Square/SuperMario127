class_name CallMethodInstruction

var scope := 0
var path := []
var args = []

func execute(environment: InterpreterEnvironment):
	var parent_key = interpreter_util.get_path_parent_key(path, environment)
	var object = parent_key[0]
	var method_name = parent_key[1]
	
	var index = 0
	for arg in args:
		args[index] = interpreter_util.decode_var(arg, environment)
		index += 1
	object.callv(method_name, args)
