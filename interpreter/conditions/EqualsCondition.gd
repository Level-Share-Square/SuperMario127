class_name EqualsCondition

var values = []

func get_value(environment: InterpreterEnvironment) -> bool:
	return interpreter_util.decode_var(values[0], environment) == interpreter_util.decode_var(values[1], environment)
	
func get_class():
	return "InterpreterCondition"
