extends RigidBody2D

onready var button = $"%Button"

var minigame
var addition: int

func _ready():
	addition = randi() % 20
	button.connect("pressed", self, "on_button_pressed")
	
func on_button_pressed():
	button.disabled = true
	minigame.update_score(addition)
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	yield(tween, "finished")
	queue_free()
