extends TextureButton


onready var animplay = $"%AnimationPlayer"
var is_in = false


# Called when the node enters the scene tree for the first time.
func _pressed():
	if is_in == false:
		animplay.play("autosave_in")
		is_in = true
	else:
		animplay.play("autosave_out")
		is_in = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
