class_name InterpreterVar

var path = []
var id = "VAR"

func get_value(environment: InterpreterEnvironment):
	return interpreter_util.get_path_value(path, environment)

func get_class():
	return "InterpreterVar"
