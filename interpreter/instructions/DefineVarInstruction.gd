class_name DefineVarInstruction

var scope := 0
var var_name : String
var var_value

func execute(environment: InterpreterEnvironment):
	environment.global[var_name] = interpreter_util.decode_var(var_value, environment)

func get_var() -> InterpreterVar:
	var interpreter_var = InterpreterVar.new()
	interpreter_var.path = ["global", var_name]
	return interpreter_var
