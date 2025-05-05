class_name BoolProperty
extends Property


export var value: bool = true


static func _decode() -> bool:
	


func _encode() -> String:
	return "BL%s" % int(value)
