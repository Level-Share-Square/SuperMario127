extends Control


onready var end_cards = $"%EndCards"


func _ready():
	for i in range(5):
		yield(get_tree(), "idle_frame")
 
	var end_cards_img: Image = end_cards.get_node("Viewport").get_texture().get_data()
	end_cards_img.convert(Image.FORMAT_RGBA8)
	end_cards_img.flip_y()
	end_cards_img.save_png("res://assets/artwork/youtube/thumbnails/thumbnail.png")
