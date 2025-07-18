class_name ActionManager
extends Node


signal undo
signal redo

var undo_stack: Array
var redo_stack: Array


func commit_action(action: Action) -> void:
	redo_stack.clear()
	
	action._do()
	undo_stack.append(action)


func undo() -> void:
	if undo_stack.empty(): return
	
	var action: Action = undo_stack.pop_back()
	action._undo()
	redo_stack.append(action)
	emit_signal("undo")


func redo() -> void:
	if redo_stack.empty(): return
	
	var action: Action = redo_stack.pop_back()
	action._do()
	undo_stack.append(action)
	emit_signal("redo")
