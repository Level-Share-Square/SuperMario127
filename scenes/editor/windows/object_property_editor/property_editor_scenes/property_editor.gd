class_name PropertyEditor
extends HBoxContainer


enum Subgroups {Bool, Misc, Dialogue, Warps}

export(Subgroups) var subgroup: int = 1

var object: GameObject
var key: String
var alias: String


func setup(value, hints: PropertyHints) -> void:
	alias = hints.alias
