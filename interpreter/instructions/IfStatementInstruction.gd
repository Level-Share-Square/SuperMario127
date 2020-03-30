class_name IfStatementInstruction

var scope := 0
var value

func execute(environment: InterpreterEnvironment):
	return 1 if interpreter_util.decode_var(value, environment) else 0
