class_name PropertyEditor
extends HBoxContainer


var object: GameObject
var key: String
var alias: String


func setup(value, hints: PropertyHints) -> void:
	alias = hints.alias
