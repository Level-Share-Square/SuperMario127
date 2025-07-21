class_name LinePropertyEditor
extends PropertyEditor


onready var label: Label = $"%Name"


func setup(value, hints: PropertyHints) -> void:
	.setup(value, hints)
	
	label.text = alias + ":"
