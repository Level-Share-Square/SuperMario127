class_name Property
extends Resource

export var name: String = "property"
export var tooltip: String = "No tooltip found."
export var editor_hint: Array = []


func _encode() -> String:
	return "NL"
