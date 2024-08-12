extends Control


onready var rating_sprite = $TextureProgress


# Called when the node enters the scene tree for the first time.
func _ready():
	rating_sprite.max_value = 5
	rating_sprite.min_value = 0
	rating_sprite.step = 0.5
	
func set_rating(rating: float) -> void:
	rating_sprite.value = rating
	


