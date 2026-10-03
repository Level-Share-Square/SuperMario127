tool
extends Sprite


export var min_scale: float
export var max_scale: float

export var scale_sine_anim_speed: float = 1.0

var anim_time: float = 0


func _process(delta):
	var new_scale = RangeSound.map(cos(anim_time), -1, 1, min_scale, max_scale)
	scale = Vector2(new_scale, new_scale)
	
	# just to make the exported number more manageable
	anim_time += scale_sine_anim_speed * delta
	anim_time = wrapf(anim_time, 0, PI * 2)
