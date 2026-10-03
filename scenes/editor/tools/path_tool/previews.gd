extends Control


func _ready():
	if get_parent().name != "ObjectTrail":
		hide()
