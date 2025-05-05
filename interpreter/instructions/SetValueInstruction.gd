class_name SetValueInstruction

var scope := 0
var path := []
var value

func execute(environment: InterpreterEnvironment):
	var parent_key = interpreter_util.get_path_parent_key(path, environment)
	var object = parent_key[0]
	var key = parent_key[1]
	
	value = interpreter_util.decode_var(value, environment)
	
	object[key] = value
