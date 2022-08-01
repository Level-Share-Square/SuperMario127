extends Label

onready var slider = $"../HSlider"

func _process(delta):
	self.text = str(slider.value) + "%"
