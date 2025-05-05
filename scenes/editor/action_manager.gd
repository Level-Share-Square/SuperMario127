extends Node

var shared_node = null
var undo_actions = []
var redo_actions = []

func undo():
	if undo_actions.size() > 0:
		redo_actions.insert(0, undo_actions[0])
		undo_actions[0].reverse(shared_node)
		undo_actions.pop_front()
		
func redo():
	if redo_actions.size() > 0:
		undo_actions.insert(0, redo_actions[0])
		redo_actions[0].execute(shared_node)
		redo_actions.pop_front()

func add_action(action):
	undo_actions.insert(0, action)
	redo_actions.clear()

func clear_history():
	undo_actions.clear()
	redo_actions.clear()
