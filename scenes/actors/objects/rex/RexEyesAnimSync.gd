tool
extends AnimatedSprite

onready var rex_sprite : AnimatedSprite = get_parent()

func _process(_delta):
	frame = rex_sprite.frame
	flip_h = rex_sprite.flip_h
	offset = rex_sprite.offset
