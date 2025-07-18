class_name SelectionTool
extends Control


onready var editor = get_tree().get_current_scene()
onready var selection_box = editor.get_node("%SelectionBox")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
