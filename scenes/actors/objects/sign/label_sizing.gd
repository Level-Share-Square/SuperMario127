extends RichTextLabel


## u may be thinking to yourself...
## "surely there's a cleaner way to do this?"
## i looked. for godot 3 there is not...
## this will have to do, unfortunately


export var max_width: float

export var width_reference_path: NodePath
onready var width_reference: Label = get_node(width_reference_path)


func update_sizing():
	width_reference.text = text
	yield(get_tree(), "idle_frame")
	rect_min_size.x = min(width_reference.rect_size.x, max_width)
