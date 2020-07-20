extends Node

onready var play_sounds = [
	["CoinSound", $CoinSound, false]
]

func PlaySound(sound_name):
	for array in play_sounds:
		if array[0] == sound_name:
			array[2] = true
			break


func _process(delta):
	for array in play_sounds:
		if array[2]:
			array[1].play()
			array[2] = false
