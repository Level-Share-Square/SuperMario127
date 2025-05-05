class_name AndCondition

var values = []

func get_value(environment: InterpreterEnvironment) -> bool:
	for value in values:
		if !interpreter_util.decode_var(value, environment):
			return false
	return true

func get_class():
	return "InterpreterCondition"
