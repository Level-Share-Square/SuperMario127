extends Button

var string

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _pressed():
	get_parent().get_parent().close()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
