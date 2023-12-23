extends Area2D
class_name EditorHitbox

var is_in_mouse: bool = false

func _ready():
	if get_tree().current_scene.name != "Editor":
		print("bye bi")
		queue_free()
		return
	connect("mouse_entered", self, "set", ["is_in_mouse", true])
	connect("mouse_exited", self, "set", ["is_in_mouse", false])
