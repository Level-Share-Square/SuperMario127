extends VBoxContainer


onready var capsule = $"%Capsule"
onready var header = $"%Header"


func _ready():
	for i in range(5):
		yield(get_tree(), "idle_frame")
		
	var capsule_img: Image = capsule.get_node("Viewport").get_texture().get_data()
	capsule_img.flip_y()
	capsule_img.save_png("res://steam/capsule.png")

	var header_img: Image = header.get_node("Viewport").get_texture().get_data()
	header_img.flip_y()
	header_img.save_png("res://steam/header.png")
