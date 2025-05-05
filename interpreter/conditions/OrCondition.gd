class_name OrCondition

var values = []

func get_value(environment: InterpreterEnvironment) -> bool:
	for value in values:
		if interpreter_util.decode_var(value, environment):
			return true
	return false

func get_class():
	return "InterpreterCondition"
