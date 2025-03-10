extends Node

onready var play_sounds = [
	["CoinSound", $CoinSound, false],
	["PurpleSound", $PurpleSound, false],
	["LaughSound", $LaughSound, false],
	["BlastLaunchSound", $BlastSound, false],
	["BlastSeekSound", $BlastSeekSound, false]
]

onready var saw_sound : AudioStreamPlayer2D = $SawSound
onready var blaster_sound : AudioStreamPlayer2D = $BlastSound

func PlaySound(sound_name):
	for array in play_sounds:
		if array[0] == sound_name:
			array[2] = true
			break

func _process(_delta):
	for array in play_sounds:
		if array[2]:
			array[1].play()
			array[2] = false
