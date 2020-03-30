class_name Addition

var values = []

func get_value(environment: InterpreterEnvironment) -> bool:
	var total = null
	var type = null
	for value in values:
		value = interpreter_util.decode_var(value, environment)
		type = typeof(value) if type == null else type		
		if total == null:
			if type == TYPE_INT or type == TYPE_REAL:
				total = 0
			elif type == TYPE_VECTOR2:
				total = Vector2()
				
		if type == TYPE_INT or type == TYPE_REAL:
			total += value
		elif type == TYPE_VECTOR2:
			total = Vector2(total.x + value.x, total.y + value.y)
			
	return total

func get_class():
	return "InterpreterVar"
