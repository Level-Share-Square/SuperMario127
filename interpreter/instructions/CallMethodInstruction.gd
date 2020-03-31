class_name CallMethodInstruction

var scope := 0
var value

func execute(environment: InterpreterEnvironment):
	interpreter_util.decode_var(value, environment)
