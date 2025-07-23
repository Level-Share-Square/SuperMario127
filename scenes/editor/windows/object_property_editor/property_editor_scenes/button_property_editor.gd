class_name ButtonPropertyEditor
extends PropertyEditor


onready var button: EditorButton = $"%Button"


func setup(value, hints: PropertyHints) -> void:
	.setup(value, hints)
	
	button.set_label_text(alias)
