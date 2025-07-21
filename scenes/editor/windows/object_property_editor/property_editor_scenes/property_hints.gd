class_name PropertyHints
extends Resource


var alias: String = "Property"
var editor: String = "base"
var tab: String = "misc"
var conditions: String = "Property"
var hints: Array = []


func _init(_alias: String, _editor: String, _tab: String, _conditions: String, _hints: Array):
	alias = _alias
	editor = _editor
	tab = _tab
	conditions = _conditions
	hints = _hints
