tool
extends SpriteAnimSync


export var source_unsquished: SpriteFrames
export var source_squished: SpriteFrames

export var target_unsquished: SpriteFrames
export var target_squished: SpriteFrames


func _process(_delta):
	if not parent_sprite: return
	
	if parent_sprite.frames == source_squished:
		frames = target_squished
	else:
		frames = target_unsquished
