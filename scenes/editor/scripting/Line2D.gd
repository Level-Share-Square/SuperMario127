extends Line2D




# Called when the node enters the scene tree for the first time.
func _ready():
	points[0] = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	points[1] = get_global_mouse_position()
