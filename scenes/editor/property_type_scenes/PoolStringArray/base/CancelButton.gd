extends Button

var string: Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _pressed():
	string.toggle_pressed()
	get_owner().close()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
