extends TextureRect


export var audio: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready():
	if audio is AudioStreamMP3:
		print(audio.data)
	elif audio is AudioStreamOGGVorbis:
		var data = audio.data
		for i in data.size()/100:
			for i2 in range(100):
				print(data[(i * 100) + i2])
			yield(get_tree(), "idle_frame")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
