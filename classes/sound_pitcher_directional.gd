extends AudioStreamPlayer2D


export var min_pitch: float = 0.8
export var max_pitch: float = 1.2


func play_rand_pitch(from_position: float = 0.0, do_pitch: bool = true) -> void:
	play(from_position, do_pitch)


func play(from_position: float = 0.0, do_pitch: bool = true) -> void:
	if do_pitch:
		pitch_scale = rand_range(min_pitch, max_pitch)
	else:
		pitch_scale = 1.0
	.play(from_position)
