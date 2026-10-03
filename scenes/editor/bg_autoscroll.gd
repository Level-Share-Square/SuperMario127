extends ParallaxLayer


export var scroll_speed: float = 0


func _process(delta):
	motion_offset.x += scroll_speed * delta
	motion_offset.x = wrapf(motion_offset.x, 0, motion_mirroring.x)
