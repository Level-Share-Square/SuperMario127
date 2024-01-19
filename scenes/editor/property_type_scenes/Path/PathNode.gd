extends Sprite

#the previous and next nodes in the path
var nextnode : Node2D
var prevnode : Node2D

func _ready():
	pass # Replace with function body.
	
func delete():
	if is_instance_valid(prevnode):
		if is_instance_valid(nextnode):
			prevnode.nextnode = nextnode
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
