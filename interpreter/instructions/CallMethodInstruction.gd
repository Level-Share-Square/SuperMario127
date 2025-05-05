class_name CallMethodInstruction

var id := 0
var scope := 0
var value

func execute(environment: InterpreterEnvironment):
	interpreter_util.decode_var(value, environment)
