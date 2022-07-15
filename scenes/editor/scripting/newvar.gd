extends WindowDialog


onready var value = get_node("Value")
onready var variable = $Var

# Called when the node enters the scene tree for the first time.
func _ready():
	get_close_button().visible = false
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
