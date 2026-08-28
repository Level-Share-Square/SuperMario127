extends AudioStreamPlayer2D


export var min_pitch: float = 0.8
export var max_pitch: float = 1.2


func play_rand_pitch(from_position: float = 0.0) -> void:
	play(from_position)


func play(from_position: float = 0.0) -> void:
	pitch_scale = rand_range(min_pitch, max_pitch)
	.play(from_position)
