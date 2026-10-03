extends Control


onready var showcase = $"%Showcase"
onready var walkthrough = $"%Walkthrough"



func _ready():
	for i in range(5):
		yield(get_tree(), "idle_frame")
 
#	var showcase_img: Image = showcase.get_node("Viewport").get_texture().get_data()
#	showcase_img.convert(Image.FORMAT_RGBA8)
#	showcase_img.flip_y()
#	showcase_img.save_png("res://assets/artwork/youtube/thumbnails/thumbnail.png")
	
	var walkthrough_img: Image = walkthrough.get_node("Viewport").get_texture().get_data()
	walkthrough_img.convert(Image.FORMAT_RGBA8)
	walkthrough_img.flip_y()
	walkthrough_img.save_png("res://assets/artwork/youtube/thumbnails/walkthrough.png")
