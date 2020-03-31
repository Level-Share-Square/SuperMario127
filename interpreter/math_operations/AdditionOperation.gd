class_name AdditionOperation

var values = []

func get_value(environment: InterpreterEnvironment) -> bool:
	var total = null
	for value in values:
		value = interpreter_util.decode_var(value, environment)
		
		if total == null:
			total = value
		else:
			total += value
		
	return total

func get_class():
	return "InterpreterVar"
