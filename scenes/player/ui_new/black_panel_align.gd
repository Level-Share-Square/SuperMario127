tool
extends Panel


func _ready():
	connect("resized", self, "resized")
	resized()


func resized():
	rect_pivot_offset.x = rect_size.x
	rect_position.x = -rect_size.x
