class_name ActionManager
extends Node


signal undo
signal redo
signal action

var undo_stack: Array
var redo_stack: Array


func commit_action(actions: Array) -> void:
	redo_stack.clear()
	
	for action in actions:
		action._do()
	undo_stack.append(actions)
	emit_signal("action")


func undo() -> void:
	if undo_stack.empty(): return
	
	var actions: Array = undo_stack.pop_back()
	for action in actions:
		action._undo()
	redo_stack.append(actions)
	emit_signal("undo")


func redo() -> void:
	if redo_stack.empty(): return
	
	var actions: Array = redo_stack.pop_back()
	for action in actions:
		action._do()
	undo_stack.append(actions)
	emit_signal("redo")
